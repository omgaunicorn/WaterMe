//
//  ReminderGedeg.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 19/10/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import RealmSwift
import Result
import Foundation

/**
 Contains a bunch of functions that take a collection of Reminders and produce indexpaths and vice versa
 IndexPaths represent reminders grouped by when they need to be performed next
 i.e. Today, Tomorrow, This Week, Later
 Gedeg == Grouper / Degrouper
 */

open class ReminderGedeg: NSObject {

    private let updateBatcher = Batcher()
    private(set) var reminders: [Reminder.Section : AnyRealmCollection<Reminder>] = [:]
    public var lastError: RealmError?

    public init?(basicRC: BasicController?) {
        super.init()
        guard let basicRC = basicRC else { return nil }
        self.updateBatcher.batchFired = { [unowned self] changes in
            self.batchedUpdates(ins: changes.ins, dels: changes.dels, mods: changes.mods)
        }
        for i in 0 ..< Reminder.Section.count {
            let section = Reminder.Section(rawValue: i)!
            let result = basicRC.reminders(in: section, sorted: .nextPerformDate, ascending: true)
            switch result {
            case .success(let reminders):
                let token = reminders.observe({ [weak self] in self?.collection(for: section, changed: $0) })
                self.tokens += [token]
            case .failure(let error):
                self.lastError = error
            }
        }
    }

    private func collection(for section: Reminder.Section, changed changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.reminders[section] = data
            if self.reminders.count == self.tokens.count {
                self.allDataReady()
            }
        case .update(_, deletions: let del, insertions: let ins, modifications: let mod):
            self.updateBatcher.appendUpdateExtendingTimer(Update(section: section, deletions: del, insertions: ins, modifications: mod))
        case .error(let error):
            BasicController.errorThrown?(error)
            log.error(error)
        }
    }

    open func allDataReady() { }

    open func batchedUpdates(ins: [IndexPath], dels: [IndexPath], mods: [IndexPath]) { }

    public var numberOfSections: Int {
        return self.reminders.count
    }

    public func numberOfItems(inSection section: Int) -> Int {
        guard let section = Reminder.Section(rawValue: section) else {
            let message = "Invalid Section Passed In"
            assertionFailure(message)
            log.error(message)
            return 0
        }
        // BUGFIX: http://crashes.to/s/12c6e5bfcd3
        // If the collectionview is too hasty when loading data
        // the data could still be NIl
        // previously this was force unwrapped
        guard let count = self.reminders[section]?.count else {
            let error = NSError(dataForSectionWasNilInNumberOfItemsInSection: section)
            assertionFailure(String(describing: error))
            BasicController.errorThrown?(error)
            log.error(error)
            return 0
        }
        return count
    }

    public func reminder(at indexPath: IndexPath) -> Reminder? {
        guard let section = Reminder.Section(rawValue: indexPath.section) else {
            let message = "Invalid Section Passed In"
            assertionFailure(message)
            log.error(message)
            return nil
        }
        // BUGFIX: http://crashes.to/s/c5852da2c75
        // If the collectionview is too hasty when loading data
        // the data could still be NIl
        // previously this was force unwrapped
        guard let reminder = self.reminders[section]?[indexPath.row] else {
            let error = NSError(dataForSectionWasNilInReminderAtIndexPath: indexPath)
            assertionFailure(String(describing: error))
            BasicController.errorThrown?(error)
            log.error(error)
            return nil
        }
        return reminder
    }

    private var tokens: [NotificationToken] = []

    deinit {
        self.tokens.forEach({ $0.invalidate() })
    }

    private class Batcher {
        private var timer: Timer?
        private var updates = [Update]()
        var batchFired: (((ins: [IndexPath], dels: [IndexPath], mods: [IndexPath])) -> Void)?
        func appendUpdateExtendingTimer(_ update: Update) {
            self.timer?.invalidate()
            self.updates.append(update)
            self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: false)
        }
        @objc private func timerFired(_ timer: Timer?) {
            timer?.invalidate()
            self.timer?.invalidate()
            self.timer = nil
            let updates = self.updates
            self.updates = []
            let ins = updates.deduplicatedIndexPaths(at: \.insertions)
            let dels = updates.deduplicatedIndexPaths(at: \.deletions)
            let mods = updates.deduplicatedIndexPaths(at:  \.modifications)
            self.batchFired?((ins, dels, mods))
        }
    }
}

fileprivate extension ReminderGedeg {
    fileprivate struct Update {
        public var section: Reminder.Section
        public var deletions: [Int]
        public var insertions: [Int]
        public var modifications: [Int]
    }
}

fileprivate extension Sequence where Iterator.Element == ReminderGedeg.Update {
    fileprivate func deduplicatedIndexPaths(at kp: KeyPath<ReminderGedeg.Update, [Int]>) -> [IndexPath] {
        let rawIndexPaths = self.flatMap() { update in
            return update[keyPath: kp].map({ IndexPath(row: $0, section: update.section.rawValue) })
        }
        let dedupedIndexPaths = Array(Set(rawIndexPaths))
        return dedupedIndexPaths
    }
}

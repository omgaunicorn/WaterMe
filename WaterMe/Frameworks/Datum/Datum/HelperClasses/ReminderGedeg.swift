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

import Foundation

/**
 Contains a bunch of functions that take a collection of Reminders and produce indexpaths and vice versa
 IndexPaths represent reminders grouped by when they need to be performed next
 i.e. Today, Tomorrow, This Week, Later
 Gedeg == Grouper / Degrouper
 */

internal class ReminderGedeg: NSObject {

    internal private(set) var reminders: [ReminderSection : ReminderCollection] = [:]
    private let updateBatcher = Batcher()
    private let changesObserved: ((GroupedReminderCollectionChange) -> Void)

    internal var allSectionsFinishedLoading: Bool {
        return self.reminders.count == self.tokens.count
    }

    internal init?(basicRC: RLM_BasicController?, observer: @escaping (GroupedReminderCollectionChange) -> Void) {
        self.changesObserved = observer
        super.init()
        guard let basicRC = basicRC else { return nil }
        self.updateBatcher.batchFired = { [unowned self] changes in
            self.changesObserved(.update(insertions: changes.ins, deletions: changes.dels, modifications: changes.mods))
        }
        for section in ReminderSection.allCases {
            let result = basicRC.reminders(in: section, sorted: .nextPerformDate, ascending: true)
            switch result {
            case .success(let reminders):
                let token = reminders.observe({ [weak self] in self?.collection(for: section, changed: $0) })
                self.tokens += [token]
            case .failure(let error):
                self.invalidate()
                self.changesObserved(.error(error: error))
                return
            }
        }
    }

    private func collection(for section: ReminderSection, changed changes: ReminderCollectionChange) {
        switch changes {
        case .initial(let data):
            self.reminders[section] = data
            if self.allSectionsFinishedLoading == true {
                self.changesObserved(.initial)
            }
        case .update(let ins, let del, let mod):
            self.updateBatcher.appendUpdateExtendingTimer(
                Update(section: section, deletions: del, insertions: ins, modifications: mod)
            )
        case .error(let error):
            self.invalidate()
            self.changesObserved(.error(error: .readError))
            log.error(error)
        }
    }

    internal var numberOfSections: Int {
        // if we haven't finished loading data, always return 0
        guard self.allSectionsFinishedLoading == true else {
            return 0
        }
        // do a sanity check just for Crashlytics
        // check if the reminders.count matches the number of sections
        // if this sanity check fails, something unexpected has happened
        let reminderCount = self.reminders.count
        if reminderCount != ReminderSection.allCases.count {
            let error = NSError(numberOfSectionsMistmatch: nil)
            assertionFailure(String(describing: error))
            log.error(error)
        }
        return reminderCount
    }

    internal func numberOfItems(inSection section: Int) -> Int {
        guard let section = ReminderSection(rawValue: section) else {
            let message = "Invalid Section Passed In"
            assertionFailure(message)
            log.error(message)
            return 0
        }
        // BUGFIX: http://crashes.to/s/12c6e5bfcd3
        // If the collectionview is too hasty when loading data
        // the data could still be NIL
        // previously this was force unwrapped
        guard let count = self.reminders[section]?.count else {
            let error = NSError(dataForSectionWasNilInNumberOfItemsInSection: section)
            assertionFailure(String(describing: error))
            log.error(error)
            return 0
        }
        return count
    }

    internal func reminder(at indexPath: IndexPath) -> ReminderWrapper? {
        guard let section = ReminderSection(rawValue: indexPath.section) else {
            let message = "Invalid Section Passed In"
            assertionFailure(message)
            log.error(message)
            return nil
        }

        let reminders = self.reminders

        // BUGFIX: http://crashes.to/s/c5852da2c75
        // If the collectionview is too hasty when loading data
        // the data could still be NIL
        // previously this was force unwrapped
        guard let data = reminders[section] else {
            let error = NSError(dataForSectionWasNilInReminderAtIndexPath: indexPath)
            assertionFailure(String(describing: error))
            log.error(error)
            return nil
        }

        // swiftlint:disable:next todo
        // FIXME: Crasher Workaround - http://crashes.to/s/ba8c0f6c9ad
        // Sometimes this method is called when an index out of bounds.
        // This should not happen, but this check works around it.
        let row = indexPath.row
        guard data.count > row else {
            let error = NSError(outOfBoundsRowAtIndexPath: indexPath)
            assertionFailure(String(describing: error))
            log.error(error)
            return nil
        }

        return data[row]
    }

    internal func indexPathOfReminder(with identifier: ReminderIdentifier) -> IndexPath? {
        var indexPath: IndexPath?
        for (section, collection) in self.reminders {
            guard let row = collection.index(matching: "uuid = %@", identifier.reminderIdentifier) else { continue }
            indexPath = IndexPath(row: row, section: section.rawValue)
        }
        return indexPath
    }

    private var tokens: [ObservationToken] = []

    private func invalidate() {
        self.tokens.forEach({ $0.invalidate() })
        self.tokens = []
    }

    deinit {
        self.invalidate()
    }

    private class Batcher {
        private var timer: Timer?
        private var updates = [Update]()
        var batchFired: (((ins: [IndexPath], dels: [IndexPath], mods: [IndexPath])) -> Void)?
        func appendUpdateExtendingTimer(_ update: Update) {
            self.timer?.invalidate()
            self.updates.append(update)
            self.timer = Timer.scheduledTimer(timeInterval: 0.001,
                                              target: self,
                                              selector: #selector(self.timerFired(_:)),
                                              userInfo: nil,
                                              repeats: false)
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

extension ReminderGedeg {
    fileprivate struct Update {
        public var section: ReminderSection
        public var deletions: [Int]
        public var insertions: [Int]
        public var modifications: [Int]
    }
}

extension Sequence where Iterator.Element == ReminderGedeg.Update {
    fileprivate func deduplicatedIndexPaths(at kp: KeyPath<ReminderGedeg.Update, [Int]>) -> [IndexPath] {
        let rawIndexPaths = self.flatMap() { update in
            return update[keyPath: kp].map({ IndexPath(row: $0, section: update.section.rawValue) })
        }
        let dedupedIndexPaths = Array(Set(rawIndexPaths))
        return dedupedIndexPaths
    }
}

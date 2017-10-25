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

    private(set) var reminders: [ReminderSection : AnyRealmCollection<Reminder>] = [:]
    public var lastError: RealmError?

    public init?(basicRC: BasicController?) {
        super.init()
        guard let basicRC = basicRC else { return nil }
        for i in 0 ..< ReminderSection.count {
            let section = ReminderSection(rawValue: i)!
            let result = basicRC.allReminders(section: section, sorted: .nextPerformDate, ascending: true)
            switch result {
            case .success(let reminders):
                let token = reminders.addNotificationBlock({ [weak self] in self?.collection(for: section, changed: $0) })
                self.tokens += [token]
            case .failure(let error):
                self.lastError = error
            }
        }
    }

    private func collection(for section: ReminderSection, changed changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.reminders[section] = data
            if self.reminders.count == self.tokens.count {
                self.allDataReady()
            }
        case .update(_, deletions: let del, insertions: let ins, modifications: let mod):
            self.updates(in: section, deletions: del, insertions: ins, modifications: mod)
        case .error(let error):
            log.error(error)
        }
    }

    open func allDataReady() { }

    open func updates(in section: ReminderSection, deletions: [Int], insertions: [Int], modifications: [Int]) { }

    public func numberOfSections() -> Int {
        return self.reminders.count
    }

    public func numberOfItems(inSection section: Int) -> Int {
        let section = ReminderSection(rawValue: section)!
        return self.reminders[section]!.count
    }

    public func reminder(at indexPath: IndexPath) -> Reminder {
        let section = ReminderSection(rawValue: indexPath.section)!
        let reminder = self.reminders[section]![indexPath.row]
        return reminder
    }

    private var tokens: [NotificationToken] = []

    deinit {
        self.tokens.forEach({ $0.stop() })
    }
}

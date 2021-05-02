//
//  CD_Reminder.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/21.
//  Copyright © 2020 Saturday Apps.
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

import CoreData

@objc(CD_Reminder)
internal class CD_Reminder: CD_Base {

    override class var entityName: String { "CD_Reminder" }
    class var request: NSFetchRequest<CD_Reminder> {
        NSFetchRequest<CD_Reminder>(entityName: self.entityName)
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.raw_kindString = ReminderKind.kCaseWaterValue
        self.raw_interval = Int32(ReminderConstants.defaultInterval)
        self.raw_isEnabled = true
    }
    
    /// Update `nextPerformDate` & `lastPerformDate` based on new date
    /// If `nil` is passed for `newDate` then current `lastPerformDate` is used for update calculation.
    internal func updateDates(withAppendedPerformDate newDate: Date? = nil) {
        if let newDate = newDate {
            self.raw_lastPerformDate = newDate
        }
        if let lastPerformDate = self.raw_lastPerformDate {
            let cal = Calendar.current
            self.raw_nextPerformDate = cal.dateByAddingNumberOfDays(Int(self.raw_interval),
                                                                to: lastPerformDate)
        } else {
            self.raw_nextPerformDate = nil
        }
    }
    
    override func willSave() {
        super.willSave()
        if let descriptionString = self.raw_descriptionString,
           descriptionString.nonEmptyString == nil
        {
            self.raw_descriptionString = nil
        }
        if let note = self.raw_note, note.nonEmptyString == nil {
            self.raw_note = nil
        }
    }
}

@objc(CD_ReminderPerform)
internal class CD_ReminderPerform: CD_Base {

    class override var entityName: String { "CD_ReminderPerform" }
    class var request: NSFetchRequest<CD_ReminderPerform> {
        NSFetchRequest<CD_ReminderPerform>(entityName: self.entityName)
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.raw_date = Date()
    }
}

extension CD_Reminder {
    static func sortDescriptor(for sortOrder: ReminderSortOrder,
                               ascending: Bool) -> NSSortDescriptor
    {
        switch sortOrder {
        case .interval:
            return .init(key: #keyPath(CD_Reminder.raw_interval), ascending: ascending)
        case .kind:
            return .init(key: #keyPath(CD_Reminder.raw_kindString), ascending: ascending)
        case .nextPerformDate:
            return .init(key: #keyPath(CD_Reminder.raw_nextPerformDate), ascending: ascending)
        case .note:
            return .init(key: #keyPath(CD_Reminder.raw_note), ascending: ascending)
        }
    }
}

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
    
    @NSManaged var interval: Int32
    @NSManaged var isEnabled: Bool
    @NSManaged var kindString: String
    @NSManaged var descriptionString: String?
    @NSManaged var nextPerformDate: Date?
    @NSManaged var lastPerformDate: Date?
    @NSManaged var note: String?
    @NSManaged var performed: NSSet
    @NSManaged var vessel: CD_ReminderVessel
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.kindString = ReminderKind.kCaseWaterValue
        self.interval = Int32(ReminderConstants.defaultInterval)
        self.isEnabled = true
    }
    
    /// Update `nextPerformDate` & `lastPerformDate` based on new date
    /// If `nil` is passed for `newDate` then current `lastPerformDate` is used for update calculation.
    internal func updateDates(withAppendedPerformDate newDate: Date? = nil) {
        if let newDate = newDate {
            self.lastPerformDate = newDate
        }
        if let lastPerformDate = self.lastPerformDate {
            let cal = Calendar.current
            self.nextPerformDate = cal.dateByAddingNumberOfDays(Int(self.interval),
                                                                to: lastPerformDate)
        } else {
            self.nextPerformDate = nil
        }
    }

    override func datum_willSave() {
        super.datum_willSave()
        if let descriptionString = self.descriptionString,
           descriptionString.nonEmptyString == nil
        {
            self.descriptionString = nil
        }
        if let note = self.note, note.nonEmptyString == nil {
            self.note = nil
        }
    }
}

@objc(CD_ReminderPerform)
internal class CD_ReminderPerform: CD_Base {

    class override var entityName: String { "CD_ReminderPerform" }
    class var request: NSFetchRequest<CD_ReminderPerform> {
        NSFetchRequest<CD_ReminderPerform>(entityName: self.entityName)
    }
    
    @NSManaged var date: Date
    @NSManaged var reminder: CD_Reminder
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        self.date = Date()
    }
}

extension CD_Reminder {
    static func sortDescriptor(for sortOrder: ReminderSortOrder,
                               ascending: Bool) -> NSSortDescriptor
    {
        switch sortOrder {
        case .interval:
            return .init(key: #keyPath(CD_Reminder.interval), ascending: ascending)
        case .kind:
            return .init(key: #keyPath(CD_Reminder.kindString), ascending: ascending)
        case .nextPerformDate:
            return .init(key: #keyPath(CD_Reminder.nextPerformDate), ascending: ascending)
        case .note:
            return .init(key: #keyPath(CD_Reminder.note), ascending: ascending)
        }
    }
}

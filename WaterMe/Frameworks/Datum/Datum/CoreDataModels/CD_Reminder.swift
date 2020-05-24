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
    
    @NSManaged var interval: Int32
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
    }
    
    internal func updateDates(basedOnAppendedPerformDate newDate: Date) {
        self.lastPerformDate = newDate
        let cal = Calendar.current
        self.nextPerformDate = cal.dateByAddingNumberOfDays(Int(self.interval),
                                                            to: newDate)
    }
}

@objc(CD_ReminderPerform)
internal class CD_ReminderPerform: CD_Base {
    @NSManaged var date: Date
    @NSManaged var reminder: CD_Reminder
}

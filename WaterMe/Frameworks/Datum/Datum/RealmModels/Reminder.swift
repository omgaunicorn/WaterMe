//
//  Reminder.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/31/17.
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

@objc(Reminder)
internal class RLM_Reminder: Object {
    @objc internal private(set) dynamic var uuid = UUID().uuidString
    @objc internal dynamic var interval = ReminderConstants.defaultInterval
    @objc internal dynamic var note: String?
    @objc internal dynamic var nextPerformDate: Date?
    @objc internal dynamic var kindString: String = RLM_Reminder.kCaseWaterValue
    @objc internal dynamic var descriptionString: String?
    @objc internal dynamic var bloop = false
    internal let performed = List<RLM_ReminderPerform>()
                           //#keyPath(__rlm_ReminderVessel.reminders)
    internal let vessels = LinkingObjects(fromType: RLM_ReminderVessel.self,
                                          property: "reminders")
    internal override class func primaryKey() -> String {
        return #keyPath(RLM_Reminder.uuid)
    }
}

@objc(ReminderPerform)
internal class RLM_ReminderPerform: Object {
    @objc internal dynamic var date = Date()
    @objc internal dynamic var bloop = false
}

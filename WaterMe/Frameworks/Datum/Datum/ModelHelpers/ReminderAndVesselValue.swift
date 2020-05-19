//
//  ReminderAndVesselValue.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/15/18.
//  Copyright © 2018 Saturday Apps.
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

public struct ReminderAndVesselValue: Hashable {

    public var reminder: ReminderValue
    public var reminderVessel: ReminderVesselValue

    public init?(reminder: ReminderWrapper?) {
        guard let reminder = reminder else { return nil }
        let _vessel = ReminderVesselValue(reminderVessel: reminder.vessel)
        guard let vessel = _vessel else { return nil }
        self.reminderVessel = vessel
        self.reminder = ReminderValue(reminder: reminder)
    }

    public static func uniqueParentPlantNames(from values: [ReminderAndVesselValue]) -> [String?] {
        let uniqueParents = Dictionary(grouping: values, by: { $0.reminderVessel.uuid })
        let parentNames = uniqueParents.map({ $0.value.first?.reminderVessel.name })
        return parentNames
    }
}

public struct ReminderValue: Hashable {

    public var uuid: ReminderIdentifier
    public var nextPerformDate: Date?
    public var kind: ReminderKind

    internal init(reminder: RLM_Reminder) {
        self.uuid = ReminderIdentifier(reminder: reminder)
        self.nextPerformDate = reminder.nextPerformDate
        self.kind = reminder.kind
    }
    public init(reminder: ReminderWrapper) {
        self.init(reminder: reminder.wrappedObject)
    }
}

public struct ReminderVesselValue: Hashable {

    public var uuid: ReminderVesselIdentifier
    public var name: String?
    public var imageData: Data?

    internal init?(reminderVessel: RLM_ReminderVessel?) {
        guard let reminderVessel = reminderVessel else { return nil }
        self.uuid = ReminderVesselIdentifier(reminderVessel: reminderVessel)
        self.name = reminderVessel.shortLabelSafeDisplayName
        self.imageData = reminderVessel.iconImageData
    }
    
    public init?(reminderVessel: ReminderVesselWrapper?) {
        self.init(reminderVessel: reminderVessel?.wrappedObject)
    }
}

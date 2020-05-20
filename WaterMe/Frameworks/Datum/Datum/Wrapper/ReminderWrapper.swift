//
//  ReminderWrapper.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/15.
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

import RealmSwift

public struct ReminderWrapper: ModelCompleteCheckable {
    internal var wrappedObject: RLM_Reminder
    internal init(_ wrappedObject: RLM_Reminder) {
        self.performed = .init(wrappedObject.performed)
        self.vessel = wrappedObject.vessel.map { RLM_ReminderVesselWrapper($0) }
        self.wrappedObject = wrappedObject
    }
    
    public static var minimumInterval: Int { RLM_Reminder.minimumInterval }
    public static var maximumInterval: Int { RLM_Reminder.maximumInterval }
    public static var defaultInterval: Int { RLM_Reminder.defaultInterval }
    
    public var kind: ReminderKind { self.wrappedObject.kind }
    public var uuid: String { self.wrappedObject.uuid }
    public var interval: Int { self.wrappedObject.interval }
    public var note: String? { self.wrappedObject.note }
    public var nextPerformDate: Date? { self.wrappedObject.nextPerformDate }
    public var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    public let vessel: ReminderVesselWrapper?
    public let performed: ReminderPerformCollection
}

public struct ReminderPerformCollection {
    private var collection: List<RLM_ReminderPerform>
    internal init(_ collection: List<RLM_ReminderPerform>) {
        self.collection = collection
    }
    
    public var count: Int { self.collection.count }
    public subscript(index: Int) -> ReminderPerformWrapper { .init(self.collection[index]) }
    public var last: ReminderPerformWrapper? {
        guard let last = self.collection.last else { return nil }
        return .init(last)
    }
}

public struct ReminderPerformWrapper {
    internal var wrappedObject: RLM_ReminderPerform
    internal init(_ wrappedObject: RLM_ReminderPerform) {
        self.wrappedObject = wrappedObject
    }
    
    public var date: Date { self.wrappedObject.date }
}

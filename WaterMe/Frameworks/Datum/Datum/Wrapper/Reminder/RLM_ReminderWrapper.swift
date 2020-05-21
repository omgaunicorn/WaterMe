//
//  RLM_ReminderWrapper.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/20.
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

internal struct RLM_ReminderWrapper: Reminder {
    internal var wrappedObject: RLM_Reminder
    internal init(_ wrappedObject: RLM_Reminder) {
        self.performed = RLM_ReminderPerformCollection(wrappedObject.performed)
        self.vessel = wrappedObject.vessel.map { RLM_ReminderVesselWrapper($0) }
        self.wrappedObject = wrappedObject
    }
    
    var kind: ReminderKind { self.wrappedObject.kind }
    var uuid: String { self.wrappedObject.uuid }
    var interval: Int { self.wrappedObject.interval }
    var note: String? { self.wrappedObject.note }
    var nextPerformDate: Date? { self.wrappedObject.nextPerformDate }
    var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    let vessel: ReminderVessel?
    let performed: ReminderPerformCollection
}

extension RLM_ReminderWrapper {
    internal func observe(_ block: @escaping (ReminderChange) -> Void) -> ObservationToken {
        return self.wrappedObject.observe { realmChange in
            switch realmChange {
            case .error(let error):
                block(.error(error))
            case .change:
                block(.change)
            case .deleted:
                block(.deleted)
            }
        }
    }
}

internal struct RLM_ReminderPerformCollection: ReminderPerformCollection {
    private var collection: List<RLM_ReminderPerform>
    init(_ collection: List<RLM_ReminderPerform>) {
        self.collection = collection
    }
    
    var count: Int { self.collection.count }
    subscript(index: Int) -> ReminderPerformWrapper { RLM_ReminderPerformWrapper(self.collection[index]) }
    var last: ReminderPerformWrapper? {
        guard let last = self.collection.last else { return nil }
        return RLM_ReminderPerformWrapper(last)
    }
}

internal struct RLM_ReminderPerformWrapper: ReminderPerformWrapper {
    internal var wrappedObject: RLM_ReminderPerform
    internal init(_ wrappedObject: RLM_ReminderPerform) {
        self.wrappedObject = wrappedObject
    }
    internal var date: Date { self.wrappedObject.date }
}

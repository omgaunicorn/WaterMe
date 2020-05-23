//
//  CD_ReminderWrapper.swift
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

import CoreData

internal struct CD_ReminderWrapper: Reminder {
    internal var wrappedObject: CD_Reminder
    internal init(_ wrappedObject: CD_Reminder, reminderController: @escaping LazyReminderController) {
        self.performed = CD_ReminderPerformCollection(wrappedObject)
        self.vessel = CD_ReminderVesselWrapper(wrappedObject.vessel, reminderController: reminderController)
        self.wrappedObject = wrappedObject
    }
    
    var kind: ReminderKind { self.wrappedObject.kind }
    var uuid: String { self.wrappedObject.objectID.uriRepresentation().absoluteString }
    var interval: Int { Int(self.wrappedObject.interval) }
    var note: String? { self.wrappedObject.note }
    var nextPerformDate: Date? { self.wrappedObject.nextPerformDate }
    var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    let vessel: ReminderVessel?
    let performed: ReminderPerformCollection

    func observe(_ block: @escaping (ReminderChange) -> Void) -> ObservationToken {
        Token.wrap { [weak wrappedObject] in
            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave,
                                                   object: nil,
                                                   queue: nil)
            { [weak wrappedObject] notification in
                guard let wrappedObject = wrappedObject else { return }
                let queue = DispatchQueue.main
                let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet
                if updatedObjects?.contains(wrappedObject) == true {
                    queue.async { block(.change) }
                    return
                }
                let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? NSSet
                if deletedObjects?.contains(wrappedObject) == true {
                    queue.async { block(.deleted) }
                    return
                }
            }
        }
    }
}

internal struct CD_ReminderPerformCollection: ReminderPerformCollection {
    private weak var wrappedObject: CD_Reminder!
    init(_ wrappedObject: CD_Reminder) {
        self.wrappedObject = wrappedObject
    }
    
    var count: Int { self.wrappedObject.performed.count }
    subscript(index: Int) -> ReminderPerformWrapper { CD_ReminderPerformWrapper(self.wrappedObject.performed[index]) }
    var last: ReminderPerformWrapper? {
        guard let last = self.wrappedObject.performed.last else { return nil }
        return CD_ReminderPerformWrapper(last)
    }
}

internal struct CD_ReminderPerformWrapper: ReminderPerformWrapper {
    internal var wrappedObject: CD_ReminderPerform
    internal init(_ wrappedObject: CD_ReminderPerform) {
        self.wrappedObject = wrappedObject
    }
    internal var date: Date { self.wrappedObject.date }
}


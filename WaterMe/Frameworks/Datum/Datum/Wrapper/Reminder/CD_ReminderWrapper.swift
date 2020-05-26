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
    
    internal let wrappedObject: CD_Reminder
    private let context: LazyContext
    
    internal init(_ wrappedObject: CD_Reminder, context: @escaping LazyContext) {
        self.context = context
        self.vessel = CD_ReminderVesselWrapper(wrappedObject.vessel, context: context)
        self.wrappedObject = wrappedObject
    }
    
    var kind: ReminderKind { self.wrappedObject.kind }
    var uuid: String { self.wrappedObject.objectID.uriRepresentation().absoluteString }
    var interval: Int { Int(self.wrappedObject.interval) }
    var note: String? { self.wrappedObject.note }
    var nextPerformDate: Date? { self.wrappedObject.nextPerformDate }
    var lastPerformDate: Date? { self.wrappedObject.lastPerformDate }
    var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    let vessel: ReminderVessel?

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
                    queue.async { block(.change(())) }
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
    
    func observePerforms(_ block: @escaping (ReminderPerformCollectionChange) -> Void) -> ObservationToken {
        fatalError("Not implemented")
    }
}


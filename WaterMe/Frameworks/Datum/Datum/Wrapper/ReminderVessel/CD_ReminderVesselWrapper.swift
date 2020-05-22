//
//  CD_ReminderVesselWrapper.swift
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

internal struct CD_ReminderVesselWrapper: ReminderVessel {
    internal let wrappedObject: CD_ReminderVessel
    internal init(_ wrappedObject: CD_ReminderVessel) {
        self.wrappedObject = wrappedObject
    }
    
    public var uuid: String { self.wrappedObject.objectID.uriRepresentation().absoluteString }
    public var displayName: String? { self.wrappedObject.displayName }
    public var icon: ReminderVesselIcon? { self.wrappedObject.icon }
    public var kind: ReminderVesselKind { self.wrappedObject.kind }
    public var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    public var shortLabelSafeDisplayName: String? { self.wrappedObject.shortLabelSafeDisplayName }
    
    func observe(_ block: @escaping (ReminderVesselChange) -> Void) -> ObservationToken {
        Token.wrap { [weak wrappedObject] in
            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave,
                                                   object: nil,
                                                   queue: nil)
            { [weak wrappedObject] notification in
                guard let wrappedObject = wrappedObject else { return }
                let queue = DispatchQueue.main
                let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet
                if updatedObjects?.contains(wrappedObject) == true {
                    queue.async {
                        // TODO: Maybe calculate the actual changes if needed
                        block(.change(changedDisplayName: true,
                                      changedIconEmoji: true,
                                      changedReminders: true,
                                      changedPointlessBloop: true))
                    }
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
    
    func observeReminders(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        fatalError()
    }
}

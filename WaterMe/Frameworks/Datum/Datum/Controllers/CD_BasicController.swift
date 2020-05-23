//
//  CD_BasicController.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/16.
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
import UIKit

internal class CD_BasicController: BasicController {

    init(kind: ControllerKind) throws {
        guard 
            let url = Bundle(for: CD_BasicController.self).url(forResource: "WaterMe",
                                                               withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
        else { throw DatumError.createError }
        let container = NSPersistentContainer(name: "WaterMe", managedObjectModel: mom)
        let lock = DispatchSemaphore(value: 0)
        var error: Error?
        container.loadPersistentStores() { _, _error in
			error = _error
            lock.signal()
        }
        lock.wait()
		guard error == nil else { throw error! }
        self.kind = .local
        self.container = container
    }

    // MARK: Properties
    
    var remindersDeleted: (([ReminderValue]) -> Void)?
    var reminderVesselsDeleted: (([ReminderVesselValue]) -> Void)?
    var userDidPerformReminder: (() -> Void)?

    let kind: ControllerKind
    private let container: NSPersistentContainer

    // MARK: Create
    
    func newReminder(for vessel: ReminderVessel) -> Result<Reminder, DatumError> {
        return .failure(.loadError)
    }
    
    func newReminderVessel(displayName: String?,
                           icon: ReminderVesselIcon?,
                           reminders: [Reminder]?) -> Result<ReminderVessel, DatumError>
    {
        let context = self.container.viewContext
        let token = context.datum_willSave()
        defer { context.datum_didSave(token) }
        let vessel = CD_ReminderVessel(context: context)
        var reminders = reminders?.compactMap { ($0 as? CD_ReminderWrapper)?.wrappedObject } ?? []
        if reminders.isEmpty {
            let newReminder = CD_Reminder(context: context)
            newReminder.vessel = vessel
            context.insert(newReminder)
            reminders.append(newReminder)
        }
        context.insert(vessel)
        do {
            try context.save()
            let wrapper = CD_ReminderVesselWrapper(vessel) {
                NSFetchedResultsController(fetchRequest: $0,
                                           managedObjectContext: context,
                                           sectionNameKeyPath: nil,
                                           cacheName: nil)
            }
            return .success(wrapper)
        } catch(let error) {
            return .failure(.writeError)
        }
    }

    // MARK: Read
    
    func allVessels() -> Result<ReminderVesselQuery, DatumError> {
        let context = self.container.viewContext
        let fr = CD_ReminderVessel.fetchRequest() as! NSFetchRequest<CD_ReminderVessel>
        fr.sortDescriptors = [NSSortDescriptor(key: #keyPath(CD_ReminderVessel.displayName), ascending: true)]
        let frc = NSFetchedResultsController<CD_ReminderVessel>(fetchRequest: fr,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let query = CD_ReminderVesselQuery(frc) {
            NSFetchedResultsController(fetchRequest: $0,
                                       managedObjectContext: context,
                                       sectionNameKeyPath: nil,
                                       cacheName: nil)
        }
        return .success(query)
    }
    
    func allReminders(sorted: ReminderSortOrder, ascending: Bool) -> Result<ReminderQuery, DatumError> {
        return .failure(.loadError)
    }
    
    func groupedReminders() -> GroupedReminderCollection {
        return CD_GroupedReminderCollectionImp()
    }
    
    func reminderVessel(matching identifier: ReminderVesselIdentifier) -> Result<ReminderVessel, DatumError> {
        return .failure(.loadError)
    }
    
    func reminder(matching identifier: ReminderIdentifier) -> Result<Reminder, DatumError> {
        return .failure(.loadError)
    }

    // MARK: Update
    
    func update(displayName: String?,
                icon: ReminderVesselIcon?,
                in vessel: ReminderVessel) -> Result<Void, DatumError>
    {
        let context = self.container.viewContext
        let token = context.datum_willSave()
        defer { context.datum_didSave(token) }
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject
        if let displayName = displayName {
            vessel.displayName = displayName
        }
        if let icon = icon {
            vessel.icon = icon
        }
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.writeError)
        }
    }
    
    func update(kind: ReminderKind?,
                interval: Int?,
                note: String?,
                in reminder: Reminder) -> Result<Void, DatumError>
    {
        return .failure(.loadError)
    }
    
    func appendNewPerformToReminders(with identifiers: [ReminderIdentifier]) -> Result<Void, DatumError> {
        return .failure(.loadError)
    }

    // MARK: Delete
    
    func delete(vessel: ReminderVessel) -> Result<Void, DatumError> {
        let context = self.container.viewContext
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject
        context.delete(vessel)
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.writeError)
        }
    }
    
    func delete(reminder: Reminder) -> Result<Void, DatumError> {
        return .failure(.loadError)
    }

    // MARK: Random
    
    func coreDataMigration(vesselName: String?,
                           vesselImage: UIImage?,
                           vesselEmoji: String?,
                           reminderInterval: NSNumber?,
                           reminderLastPerformDate: Date?) -> Result<Void, DatumError>
    {
        return .failure(.loadError)
    }
}

extension NSManagedObjectContext {
    fileprivate func datum_willSave() -> Any {
        return NotificationCenter.default.addObserver(forName: .NSManagedObjectContextWillSave,
                                                      object: self,
                                                      queue: nil)
        { notification in
            guard let context = notification.object as? NSManagedObjectContext else {
                assertionFailure("Core Data Dates Not Updated")
                return
            }
            context.insertedObjects
                .union(context.updatedObjects)
                .forEach { ($0 as? CD_Base)?.datum_willSave() }
        }
    }
    
    fileprivate func datum_didSave(_ token: Any) {
        NotificationCenter.default.removeObserver(token)
    }
}

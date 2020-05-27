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
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject
        let context = self.container.viewContext
        let token = context.datum_willSave()
        defer { context.datum_didSave(token) }
        let reminder = CD_Reminder(context: context)
        let mutable = vessel.mutableSetValue(forKey: #keyPath(CD_ReminderVessel.reminders))
        mutable.add(reminder)
        do {
            try context.save()
            let wrapper = CD_ReminderWrapper(reminder, context: { self.container.viewContext })
            return .success(wrapper)
        } catch {
            return .failure(.writeError)
        }
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
            let wrapper = CD_ReminderVesselWrapper(vessel, context: { self.container.viewContext })
            return .success(wrapper)
        } catch {
            return .failure(.writeError)
        }
    }

    // MARK: Read
    
    internal func allVessels() -> Result<AnyCollectionQuery<ReminderVessel, Int>, DatumError> {
        let context = self.container.viewContext
        let fr = CD_ReminderVessel.fetchRequest() as! NSFetchRequest<CD_ReminderVessel>
        fr.sortDescriptors = [NSSortDescriptor(key: #keyPath(CD_ReminderVessel.displayName), ascending: true)]
        let frc = NSFetchedResultsController<CD_ReminderVessel>(fetchRequest: fr,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let query = CD_ReminderVesselQuery(frc, context: { self.container.viewContext })
        return .success(AnyCollectionQuery(query))
    }
    
    func allReminders(sorted: ReminderSortOrder,
                      ascending: Bool) -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    {
        let context = self.container.viewContext
        let fr = CD_Reminder.fetchRequest() as! NSFetchRequest<CD_Reminder>
        fr.sortDescriptors = [NSSortDescriptor(key: #keyPath(CD_Reminder.nextPerformDate), ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fr,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let query = CD_ReminderQuery(frc, context: { self.container.viewContext })
        return .success(AnyCollectionQuery(query))
    }
    
    internal func groupedReminders() -> Result<AnyCollectionQuery<Reminder, IndexPath>, DatumError> {
        var failure: DatumError?
        let _queries = ReminderSection.allCases.compactMap
        { section -> (ReminderSection, AnyCollectionQuery<Reminder, Int>)? in
            let result = self.reminders(in: section)
            switch result {
            case .failure(let error):
                failure = error
                return nil
            case .success(let query):
                return (section, query)
            }
        }
        if let failure = failure { return .failure(failure) }
        let queries = Dictionary(_queries) { (first, _) in first }
        let query = GroupedCollection(queries: queries)
        return .success(AnyCollectionQuery(query))
    }

    private func reminders(in section: ReminderSection,
                           sorted: ReminderSortOrder = .nextPerformDate,
                           ascending: Bool = true)
                           -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    {
        let fetchRequest = CD_Reminder.fetchRequest() as! NSFetchRequest<CD_Reminder>
        fetchRequest.sortDescriptors = [CD_Reminder.sortDescriptor(for: sorted, ascending: ascending)]
        let range = section.dateInterval
        let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(CD_Reminder.nextPerformDate)),
                                  rightExpression: NSExpression(forConstantValue: range.start),
                                  modifier: .direct,
                                  type: .greaterThanOrEqualTo),
            NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(CD_Reminder.nextPerformDate)),
                                  rightExpression: NSExpression(forConstantValue: range.end),
                                  modifier: .direct,
                                  type: .lessThan)
        ])
        if case .late = section {
            let nilCheck = NSComparisonPredicate(
                leftExpression: NSExpression(forKeyPath:#keyPath(CD_Reminder.nextPerformDate)),
                rightExpression: NSExpression(forConstantValue: nil),
                modifier: .direct,
                type: .equalTo
            )
            let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [nilCheck, andPredicate])
            fetchRequest.predicate = orPredicate
        } else {
            fetchRequest.predicate = andPredicate
        }
        let context = self.container.viewContext
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        let query = CD_ReminderQuery(controller, context: { self.container.viewContext })
        return .success(AnyCollectionQuery(query))
    }

    
    func reminderVessel(matching _id: Identifier) -> Result<ReminderVessel, DatumError> {
        let coordinator = self.container.persistentStoreCoordinator
        let context = self.container.viewContext
        guard
            let id = coordinator.managedObjectID(forURIRepresentation: URL(string: _id.uuid)!),
            let reminderVessel = context.object(with: id) as? CD_ReminderVessel
        else { return .failure(.objectDeleted) }
        return .success(CD_ReminderVesselWrapper(reminderVessel, context: { self.container.viewContext }))
    }
    
    func reminder(matching _id: Identifier) -> Result<Reminder, DatumError> {
        let coordinator = self.container.persistentStoreCoordinator
        let context = self.container.viewContext
        guard
            let id = coordinator.managedObjectID(forURIRepresentation: URL(string: _id.uuid)!),
            let reminder = context.object(with: id) as? CD_Reminder
        else { return .failure(.objectDeleted) }
        return .success(CD_ReminderWrapper(reminder, context: { self.container.viewContext }))
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
        vessel.reminders.forEach { ($0 as! CD_Base).bloop.toggle() }
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
        let context = self.container.viewContext
        let token = context.datum_willSave()
        defer { context.datum_didSave(token) }
        let reminder = (reminder as! CD_ReminderWrapper).wrappedObject
        if let kind = kind {
            reminder.kind = kind
        }
        if let interval = interval {
            reminder.interval = Int32(interval)
        }
        if let note = note {
            reminder.note = note
        }
        reminder.vessel.bloop.toggle()
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.writeError)
        }
    }
    
    func appendNewPerformToReminders(with _ids: [Identifier]) -> Result<Void, DatumError> {
        let coordinator = self.container.persistentStoreCoordinator
        let ids = _ids.compactMap { coordinator.managedObjectID(forURIRepresentation: URL(string: $0.uuid)!) }
        assert(ids.count == _ids.count, "We lost an object")
        let context = self.container.viewContext
        let token = context.datum_willSave()
        defer { context.datum_didSave(token) }
        let reminders = ids.compactMap { context.object(with: $0) as? CD_Reminder }
        assert(reminders.count == _ids.count, "We lost an object")
        reminders.forEach { reminder in
            let perform = CD_ReminderPerform(context: context)
            context.insert(perform)
            perform.reminder = reminder
            let mutable = reminder.mutableSetValue(forKey: #keyPath(CD_Reminder.performed))
            mutable.add(perform)
            reminder.updateDates(basedOnAppendedPerformDate: perform.date)
        }
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.writeError)
        }
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
        let context = self.container.viewContext
        let reminder = (reminder as! CD_ReminderWrapper).wrappedObject
        context.delete(reminder)
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(.writeError)
        }
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

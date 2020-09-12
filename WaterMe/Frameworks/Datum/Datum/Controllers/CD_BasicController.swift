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
import Calculate

internal class CD_BasicController: BasicController {
    
    private class func container(forTesting: Bool) -> NSPersistentContainer? {
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        guard
            let url = Bundle(for: CD_BasicController.self)
                            .url(forResource: "WaterMe", withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
        else { return nil }
        
        // when not testing, return normal persistent container
        guard forTesting else {
            return WaterMe_PersistentContainer(name: "WaterMe", managedObjectModel: mom)
        }
        
        // when testing make in-memory container
        let randomName = String(Int.random(in: 100_000...1_000_000))
        let container = WaterMe_PersistentContainer(name: randomName, managedObjectModel: mom)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        return container
    }

    init(kind: ControllerKind, forTesting: Bool) throws {
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        guard let container = CD_BasicController.container(forTesting: forTesting)
            else { throw DatumError.loadError }
        type(of: self).copySampleDBIfNeeded()
        let lock = DispatchSemaphore(value: 0)
        var error: Error?
        container.loadPersistentStores() { _, _error in
			error = _error
            lock.signal()
        }
        lock.wait()
		guard error == nil else { throw error! }
        container.viewContext.automaticallyMergesChangesFromParent = true
        let fetchRequest = CD_VesselShare.request
        let ctx = container.viewContext
        let fetchResult = try ctx.fetch(fetchRequest)
        if fetchResult.isEmpty {
            let share = CD_VesselShare(context: ctx)
            ctx.insert(share)
            try ctx.save()
        }
        self.kind = .local
        self.container = container
    }

    // MARK: Properties
    
    internal var remindersDeleted: ((Set<ReminderValue>) -> Void)?
    internal var reminderVesselsDeleted: ((Set<ReminderVesselValue>) -> Void)?
    internal var userDidPerformReminder: ((Set<ReminderValue>) -> Void)?

    internal let kind: ControllerKind
    // Internal only for testing. Should be private.
    internal let container: NSPersistentContainer

    // MARK: Create
    
    func newReminder(for vessel: ReminderVessel) -> Result<Reminder, DatumError> {
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject
        let context = self.container.viewContext
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === vessel.managedObjectContext!)
        
        let token = self.willSave(context)
        defer { self.didSave(token) }
        let newReminder = CD_Reminder(context: context)
        context.insert(newReminder)
        // core data hooks up the inverse relationship
        newReminder.vessel = vessel
        do {
            try context.save()
            let wrapper = CD_ReminderWrapper(newReminder, context: { self.container.viewContext })
            return .success(wrapper)
        } catch {
            log.error(error)
            return .failure(.writeError)
        }
    }
    
    func newReminderVessel(displayName: String?,
                           icon: ReminderVesselIcon?)
                           -> Result<ReminderVessel, DatumError>
    {
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }
        let vessel = CD_ReminderVessel(context: context)
        // enforce at least 1 reminder
        let newReminder = CD_Reminder(context: context)
        context.insert(newReminder)
        context.insert(vessel)
        // core data hooks up the inverse relationship
        newReminder.vessel = vessel
        if let displayName = displayName {
            vessel.displayName = displayName
        }
        if let icon = icon {
            vessel.icon = icon
        }
        do {
            let vesselShares = try context.fetch(CD_VesselShare.request)
            guard vesselShares.count == 1 else {
                let message = "Unexpected number of VesselShare objects: \(vesselShares.count)"
                log.error(message)
                assertionFailure(message)
                return .failure(.writeError)
            }
            vessel.share = vesselShares.first!
            try context.save()
            let wrapper = CD_ReminderVesselWrapper(vessel, context: { self.container.viewContext })
            return .success(wrapper)
        } catch {
            log.error(error)
            return .failure(.writeError)
        }
    }

    // MARK: Read
    
    internal func allVessels(sorted: ReminderVesselSortOrder,
                             ascending: Bool)
                             -> Result<AnyCollectionQuery<ReminderVessel, Int>, DatumError>
    {
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        let context = self.container.viewContext
        let fr = CD_ReminderVessel.request
        fr.sortDescriptors = [CD_ReminderVessel.sortDescriptor(for: sorted, ascending: ascending)]
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
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        let context = self.container.viewContext
        let fr = CD_Reminder.request
        fr.sortDescriptors = [CD_Reminder.sortDescriptor(for: sorted, ascending: ascending)]
        let frc = NSFetchedResultsController(fetchRequest: fr,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: nil,
                                             cacheName: nil)
        let query = CD_ReminderQuery(frc, context: { self.container.viewContext })
        return .success(AnyCollectionQuery(query))
    }
    
    internal func groupedReminders() -> Result<AnyCollectionQuery<Reminder, IndexPath>, DatumError> {
        // debug only sanity checks
        assert(Thread.isMainThread)
        
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
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        let fetchRequest = CD_Reminder.request
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
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        
        guard
            let id = coordinator.managedObjectID(forURIRepresentation: URL(string: _id.uuid)!),
            let reminderVessel = context.object(with: id) as? CD_ReminderVessel
        else { return .failure(.objectDeleted) }
        return .success(CD_ReminderVesselWrapper(reminderVessel, context: { self.container.viewContext }))
    }
    
    func reminder(matching _id: Identifier) -> Result<Reminder, DatumError> {
        let coordinator = self.container.persistentStoreCoordinator
        let context = self.container.viewContext
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        
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
        let token = self.willSave(context)
        defer { self.didSave(token) }
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === vessel.managedObjectContext)
        
        var somethingChanged = false
        if let displayName = displayName, vessel.displayName != displayName {
            somethingChanged = true
            vessel.displayName = displayName
        }
        if let icon = icon, icon != vessel.icon {
            somethingChanged = true
            vessel.icon = icon
        }
        guard somethingChanged else { return .success(()) }
        vessel.reminders.forEach { ($0 as! CD_Base).bloop.toggle() }
        do {
            try context.save()
            return .success(())
        } catch {
            log.error(error)
            return .failure(.writeError)
        }
    }
    
    func update(kind: ReminderKind?,
                interval: Int?,
                note: String?,
                in reminder: Reminder) -> Result<Void, DatumError>
    {
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }
        let reminder = (reminder as! CD_ReminderWrapper).wrappedObject
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === reminder.managedObjectContext)
        
        var somethingChanged = false
        if let kind = kind, kind != reminder.kind {
            somethingChanged = true
            reminder.kind = kind
        }
        if let interval = interval {
            let converted = Int32(interval)
            if converted != reminder.interval {
                somethingChanged = true
                reminder.interval = converted
            }
        }
        if let note = note, note != reminder.note {
            somethingChanged = true
            reminder.note = note
        }
        guard somethingChanged else { return .success(()) }
        reminder.vessel.bloop.toggle()
        do {
            try context.save()
            return .success(())
        } catch {
            log.error(error)
            return .failure(.writeError)
        }
    }
    
    func appendNewPerformToReminders(with _ids: [Identifier]) -> Result<Void, DatumError> {
        let coordinator = self.container.persistentStoreCoordinator
        let ids = _ids.compactMap {
            coordinator.managedObjectID(forURIRepresentation: URL(string: $0.uuid)!)
        }
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }
        let reminders = ids.compactMap { context.object(with: $0) as? CD_Reminder }
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(ids.count == _ids.count, "We lost an object")
        assert(reminders.count == _ids.count, "We lost an object")
        
        reminders.forEach { reminder in
            let perform = CD_ReminderPerform(context: context)
            context.insert(perform)
            // core data hooks up the inverse relationship
            perform.reminder = reminder
            reminder.updateDates(basedOnAppendedPerformDate: perform.date)
        }
        do {
            try context.save()
            return .success(())
        } catch {
            log.error(error)
            return .failure(.writeError)
        }
    }

    // MARK: Delete
    
    func delete(vessel: ReminderVessel) -> Result<Void, DatumError> {
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }
        let vessel = (vessel as! CD_ReminderVesselWrapper).wrappedObject
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === vessel.managedObjectContext)
        
        context.delete(vessel)
        do {
            try context.save()
            return .success(())
        } catch {
            log.error(error)
            return .failure(.writeError)
        }
    }
    
    func delete(reminder: Reminder) -> Result<Void, DatumError> {
        let context = self.container.viewContext
        let token = self.willSave(context)
        defer { self.didSave(token) }
        let reminder = (reminder as! CD_ReminderWrapper).wrappedObject
        
        // debug only sanity checks
        assert(Thread.isMainThread)
        assert(context === reminder.managedObjectContext)
        
        context.delete(reminder)
        do {
            try context.save()
            return .success(())
        } catch {
            log.error(error)
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

extension CD_BasicController {
    fileprivate func willSave(_ context: NSManagedObjectContext) -> Any {
        return NotificationCenter.default.addObserver(forName: .NSManagedObjectContextWillSave,
                                                      object: context,
                                                      queue: nil)
        { [weak self] notification in
            guard let context = notification.object as? NSManagedObjectContext else {
                assertionFailure("Core Data Dates Not Updated")
                return
            }
            // Update Save Modified Dates in Objects
            context.insertedObjects
                .union(context.updatedObjects)
                .forEach { ($0 as? CD_Base)?.datum_willSave() }

            // Capture Deleted Values for API Contract
            // This must be done now because they will be deleted soon
            let performedReminders = context.insertedObjects
                .compactMap { ReminderValue(reminder: ($0 as? CD_ReminderPerform)?.reminder) }
            let deletedReminders = context.deletedObjects
                .compactMap { ReminderValue(reminder: $0 as? CD_Reminder) }
            let deletedReminderVessels = context.deletedObjects
                .compactMap { ReminderVesselValue(reminderVessel: $0 as? CD_ReminderVessel) }

            // Now, Dispatch because we want CoreData to save
            // Then we can update any API Contracts
            DispatchQueue.main.async {
                if !performedReminders.isEmpty {
                    self?.userDidPerformReminder?(Set(performedReminders))
                }
                if !deletedReminders.isEmpty {
                    self?.remindersDeleted?(Set(deletedReminders))
                }
                if !deletedReminderVessels.isEmpty {
                    self?.reminderVesselsDeleted?(Set(deletedReminderVessels))
                }
            }
        }
    }
    
    fileprivate func didSave(_ token: Any) {
        NotificationCenter.default.removeObserver(token)
    }
}

// MARK: First Launch

extension CD_BasicController {

    private static let sampleDB1URL = Bundle.main.url(forResource: "StarterData", withExtension: "sqlite")
    private static let sampleDB2URL = Bundle.main.url(forResource: "StarterData", withExtension: "sqlite-wal")

    internal class var storeDirectoryURL: URL {
        let appsupport = FileManager.default.urls(
            for: FileManager.SearchPathDirectory.applicationSupportDirectory,
            in: FileManager.SearchPathDomainMask.userDomainMask
        ).first!
        let url = appsupport.appendingPathComponent("WaterMe", isDirectory: true)
                            .appendingPathComponent("CoreData", isDirectory: true)
        return url
    }

    private class var dbFileURL1: URL {
        return self.storeDirectoryURL.appendingPathComponent("WaterMe.sqlite",
                                                          isDirectory: false)
    }

    private class var dbFileURL2: URL {
        return self.storeDirectoryURL.appendingPathComponent("WaterMe.sqlite-wal",
                                                          isDirectory: false)
    }

    internal class var storeExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.dbFileURL1.path)
        return exists
    }

    private class func copySampleDBIfNeeded() {
        guard
            !RLM_BasicController.storeExists,
            !self.storeExists,
            let sampleDB1URL = self.sampleDB1URL,
            let sampleDB2URL = self.sampleDB2URL
        else { return }
        let fm = FileManager.default
        try? fm.createDirectory(at: self.storeDirectoryURL,
                                withIntermediateDirectories: true,
                                attributes: nil)
        do {
            try fm.copyItem(at: sampleDB1URL, to: self.dbFileURL1)
            try fm.copyItem(at: sampleDB2URL, to: self.dbFileURL2)
        } catch {
            log.error(error)
            try? fm.removeItem(at: self.storeDirectoryURL)
        }
    }
}

private class WaterMe_PersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CD_BasicController.storeDirectoryURL
    }
}

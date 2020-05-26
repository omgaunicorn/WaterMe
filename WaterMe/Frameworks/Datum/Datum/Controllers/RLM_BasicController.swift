//
//  BasicController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/18/17.
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
import UIKit

extension Realm {
    internal func waterMe_commitWrite() -> Result<Void, DatumError> {
        do {
            try self.commitWrite()
            return .success(())
        } catch {
            log.error(error)
            return .failure(.writeError)
        }
    }
}

internal class RLM_BasicController: BasicController {

    // MARK: Observation Closures

    internal var remindersDeleted: (([ReminderValue]) -> Void)?
    internal var reminderVesselsDeleted: (([ReminderVesselValue]) -> Void)?
    internal var userDidPerformReminder: (() -> Void)?
    
    // MARK: Initialization

    internal let kind: ControllerKind
    private let config: Realm.Configuration
    private var realm: Result<Realm, DatumError> {
        do {
            return try .success(Realm(configuration: self.config))
        } catch {
            log.error(error)
            return .failure(.loadError)
        }
    }

    internal init(kind: ControllerKind) throws {
        self.kind = kind
        var realmConfig = Realm.Configuration()
        realmConfig.schemaVersion = 14
        realmConfig.objectTypes = [RLM_ReminderVessel.self, RLM_Reminder.self, RLM_ReminderPerform.self]
        switch kind {
        case .local:
            try type(of: self).createLocalRealmDirectoryIfNeeded()
            try type(of: self).copyRealmFromBundleIfNeeded()
            realmConfig.fileURL = type(of: self).localRealmFile
        case .sync: /*(let user)*/
            // let url = user.realmURL(withAppName: "WaterMeBasic")
            fatalError("Syncing Realms are Not Implemented for WaterMe Yet")
        }
        self.config = realmConfig
    }
    
    // MARK: WaterMeClient API

    internal func allVessels() -> Result<AnyCollectionQuery<ReminderVessel, Int>, DatumError> {
        return self.realm.map() { realm in
            let kp = #keyPath(RLM_ReminderVessel.displayName)
            let collection = realm.objects(RLM_ReminderVessel.self).sorted(byKeyPath: kp)
            return AnyCollectionQuery(
                RLM_ReminderVesselQuery(
                    AnyRealmCollection(collection)
                )
            )
        }
    }

    internal func allReminders(sorted: ReminderSortOrder = .nextPerformDate,
                               ascending: Bool = true)
                               -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    {
        return self.realm.map {
            AnyCollectionQuery(
                RLM_ReminderQuery(
                    AnyRealmCollection($0.objects(RLM_Reminder.self)
                        .sorted(byKeyPath: sorted.keyPath,
                                ascending: ascending)
                    )
                )
            )
        }
    }

    internal func groupedReminders() -> GroupedReminderCollection {
        return RLM_GroupedReminderCollectionImp(basicController: self)
    }

    internal func reminders(in section: ReminderSection,
                            sorted: ReminderSortOrder = .nextPerformDate,
                            ascending: Bool = true)
                            -> Result<AnyCollectionQuery<Reminder, Int>, DatumError>
    {
        return self.realm.map() { realm in
            let range = section.dateInterval
            let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(RLM_Reminder.nextPerformDate)),
                                      rightExpression: NSExpression(forConstantValue: range.start),
                                      modifier: .direct,
                                      type: .greaterThanOrEqualTo),
                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(RLM_Reminder.nextPerformDate)),
                                      rightExpression: NSExpression(forConstantValue: range.end),
                                      modifier: .direct,
                                      type: .lessThan)
                ])
            if case .late = section {
                let nilCheck = NSComparisonPredicate(
                    leftExpression: NSExpression(forKeyPath:#keyPath(RLM_Reminder.nextPerformDate)),
                    rightExpression: NSExpression(forConstantValue: nil),
                    modifier: .direct,
                    type: .equalTo
                )
                let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [nilCheck, andPredicate])
                let collection = realm.objects(RLM_Reminder.self).filter(orPredicate).sorted(byKeyPath: sorted.keyPath, ascending: ascending)
                return AnyCollectionQuery(RLM_ReminderQuery(AnyRealmCollection(collection)))
            } else {
                let collection = realm.objects(RLM_Reminder.self).filter(andPredicate).sorted(byKeyPath: sorted.keyPath, ascending: ascending)
                return AnyCollectionQuery(RLM_ReminderQuery(AnyRealmCollection(collection)))
            }
        }
    }

    internal func appendNewPerformToReminders(with identifiers: [Identifier]) -> Result<Void, DatumError> {
        let result = self.reminders(matching: identifiers).flatMap({ self.appendNewPerform(to: $0) })
        self.userDidPerformReminder?()
        return result
    }

    internal func reminderVessel(matching identifier: Identifier) -> Result<ReminderVessel, DatumError> {
        return self.realm.flatMap() { realm -> Result<ReminderVessel, DatumError> in
            guard let reminder = realm.object(ofType: RLM_ReminderVessel.self, forPrimaryKey: identifier.uuid)
            else { return .failure(.objectDeleted) }
            return .success(RLM_ReminderVesselWrapper(reminder))
        }
    }

    internal func reminder(matching identifier: Identifier) -> Result<Reminder, DatumError> {
        return self.realm.flatMap() { realm -> Result<Reminder, DatumError> in
            guard let reminder = realm.object(ofType: RLM_Reminder.self, forPrimaryKey: identifier.uuid)
            else { return .failure(.objectDeleted) }
            return .success(RLM_ReminderWrapper(reminder))
        }
    }

    internal func reminders(matching identifiers: [Identifier]) -> Result<[RLM_Reminder], DatumError> {
        return self.realm.map() { realm in
            return identifiers.compactMap({ realm.object(ofType: RLM_Reminder.self, forPrimaryKey: $0.uuid) })
        }
    }

    internal func appendNewPerform(to reminders: [RLM_Reminder]) -> Result<Void, DatumError> {
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            for reminder in reminders {
                // append the perform
                let newPerform = RLM_ReminderPerform()
                reminder.performed.append(newPerform)
                reminder.recalculateNextPerformDate(comparisonPerform: newPerform)
                // perform bloops to force notification firing
                reminder.vessel?.bloop = !(reminder.vessel?.bloop ?? true)
            }
            return realm.waterMe_commitWrite()
        }
    }
    
    internal func newReminder(for vessel: ReminderVessel) -> Result<Reminder, DatumError> {
        let vessel = (vessel as! RLM_ReminderVesselWrapper).wrappedObject
        return self.realm.flatMap() { realm in
            let reminder = RLM_Reminder()
            realm.beginWrite()
            realm.add(reminder)
            vessel.reminders.append(reminder)
            return realm.waterMe_commitWrite().map({ RLM_ReminderWrapper(reminder) })
        }
    }
    
    internal func newReminderVessel(displayName: String? = nil, icon: ReminderVesselIcon? = nil, reminders: [Reminder]? = nil) -> Result<ReminderVessel, DatumError> {
        return self.realm.flatMap() { realm in
            let v = RLM_ReminderVessel()
            if let displayName = displayName?.nonEmptyString { // make sure the string is not empty
                v.displayName = displayName
            }
            if let icon = icon {
                v.icon = icon
            }
            if let reminders = reminders, reminders.isEmpty == false {
                v.reminders.append(objectsIn: reminders.map({ ($0 as! RLM_ReminderWrapper).wrappedObject }))
            } else {
                // enforce at least one reminder rule
                let reminder = RLM_Reminder()
                v.reminders.append(reminder)
            }
            realm.beginWrite()
            realm.add(v)
            return realm.waterMe_commitWrite().map({ RLM_ReminderVesselWrapper(v) })
        }
    }
    
    internal func update(displayName: String? = nil,
                       icon: ReminderVesselIcon? = nil,
                       in vessel: ReminderVessel) -> Result<Void, DatumError>
    {
        let vessel = (vessel as! RLM_ReminderVesselWrapper).wrappedObject
        guard vessel.isInvalidated == false else { return .failure(.objectDeleted) }
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            if let displayName = displayName {
                // make sure the string is not empty. If it is empty, set it to NIL
                vessel.displayName = displayName.nonEmptyString
            }
            if let icon = icon {
                vessel.icon = icon
                if vessel.icon == nil {
                    // something went wrong. We need to close the realm and present an error
                    _ = realm.waterMe_commitWrite()
                    return .failure(.imageCouldntBeCompressedEnough)
                }
            }
            // trigger the bloop so notifications fire for the reminder table view
            for reminder in vessel.reminders {
                reminder.bloop = !reminder.bloop
                for perform in reminder.performed {
                    perform.bloop = !perform.bloop
                }
            }
            return realm.waterMe_commitWrite()
        }
    }
    
    internal func update(kind: ReminderKind? = nil,
                       interval: Int? = nil,
                       note: String? = nil,
                       in reminder: Reminder) -> Result<Void, DatumError>
    {
        let reminder = (reminder as! RLM_ReminderWrapper).wrappedObject
        guard reminder.isInvalidated == false else { return .failure(.objectDeleted) }
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            if let kind = kind {
                reminder.kind = kind
            }
            if let interval = interval {
                reminder.interval = interval
                reminder.recalculateNextPerformDate()
            }
            if let note = note {
                // make sure the string is not empty. If it is empty, set it to blank string
                reminder.note = note.nonEmptyString
            }
            // trigger bloops so notifications fire
            reminder.vessel?.bloop = !(reminder.vessel?.bloop ?? true)
            for perform in reminder.performed {
                perform.bloop = !perform.bloop
            }
            return realm.waterMe_commitWrite()
        }
    }

    internal func coreDataMigration(vesselName: String?,
                                    vesselImage: UIImage?,
                                    vesselEmoji: String?,
                                    reminderInterval: NSNumber?,
                                    reminderLastPerformDate: Date?) -> Result<Void, DatumError>
    {
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            let vessel = RLM_ReminderVessel()
            vessel.displayName = vesselName
            vessel.icon = ReminderVesselIcon(rawImage: vesselImage, emojiString: vesselEmoji)
            let reminder = RLM_Reminder()
            reminder.interval = reminderInterval?.intValue ?? -1
            if let lastPerformDate = reminderLastPerformDate {
                let performed = RLM_ReminderPerform()
                performed.date = lastPerformDate
                reminder.performed.append(performed)
                reminder.recalculateNextPerformDate()
            }
            vessel.reminders.append(reminder)
            realm.add(vessel)
            return realm.waterMe_commitWrite()
        }
    }
        
    internal func delete(vessel: ReminderVessel) -> Result<Void, DatumError> {
        let vessel = (vessel as! RLM_ReminderVesselWrapper).wrappedObject
        let reminderValues = Array(vessel.reminders.map({ ReminderValue(reminder: $0) }))
        let vesselValue = ReminderVesselValue(reminderVessel: vessel)
        let result: Result<Void, DatumError> = self.realm.flatMap() { realm in
            realm.beginWrite()
            self.delete(vessel: vessel, inOpenRealm: realm)
            return realm.waterMe_commitWrite()
        }
        if case .success = result {
            self.remindersDeleted?(reminderValues)
            self.reminderVesselsDeleted?([vesselValue].compactMap({ $0 }))
        }
        return result
    }
    
    private func delete(vessel: RLM_ReminderVessel, inOpenRealm realm: Realm) {
        for reminder in vessel.reminders {
            self.delete(reminder: reminder, inOpenRealm: realm)
        }
        realm.delete(vessel)
    }
        
    internal func delete(reminder: Reminder) -> Result<Void, DatumError> {
        let reminder = (reminder as! RLM_ReminderWrapper).wrappedObject
        if let vessel = reminder.vessel, vessel.reminders.count <= 1 {
            return .failure(.unableToDeleteLastReminder) 
        }
        let reminderValue = ReminderValue(reminder: reminder)
        let result: Result<Void, DatumError> = self.realm.flatMap() { realm in
            realm.beginWrite()
            self.delete(reminder: reminder, inOpenRealm: realm)
            return realm.waterMe_commitWrite()
        }
        if case .success = result {
            self.remindersDeleted?([reminderValue])
        }
        return result
    }
    
    private func delete(reminder: RLM_Reminder, inOpenRealm realm: Realm) {
        for perform in reminder.performed {
            realm.delete(perform)
        }
        realm.delete(reminder)
    }
}

extension RLM_BasicController {
    private class var localRealmDirectory: URL {
        let appsupport = FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        let url = appsupport.appendingPathComponent("WaterMe", isDirectory: true).appendingPathComponent("Free", isDirectory: true)
        return url
    }

    public class var localRealmExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.localRealmFile.path)
        return exists
    }

    private class var legacyCoreDataStoreExists: Bool {
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeDirectory = appSupport.appendingPathComponent("WaterMe", isDirectory: true)
        let storeURL = storeDirectory.appendingPathComponent("WaterMeData.sqlite")
        return fm.fileExists(atPath: storeURL.path)
    }

    private class var localRealmFile: URL {
        return self.localRealmDirectory.appendingPathComponent("Realm.realm", isDirectory: false)
    }

    private class func createLocalRealmDirectoryIfNeeded() throws {
        guard self.localRealmExists == false else { return }
        try FileManager.default.createDirectory(at: self.localRealmDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    private class func copyRealmFromBundleIfNeeded() throws {
        guard
            self.localRealmExists == false,
            self.legacyCoreDataStoreExists == false,
            let bundleURL = Bundle.main.url(forResource: "StarterRealm", withExtension: "realm")
        else { return }
        try FileManager.default.copyItem(at: bundleURL, to: self.localRealmFile)
    }
}

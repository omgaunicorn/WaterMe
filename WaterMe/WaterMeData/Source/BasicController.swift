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
import Result

public protocol HasBasicController {
    var basicRC: BasicController? { get set }
}

public extension HasBasicController {
    public mutating func configure(with basicRC: BasicController?) {
        guard let basicRC = basicRC else { return }
        self.basicRC = basicRC
    }
}

internal extension Realm {
    internal func waterMe_commitWrite() -> Result<Void, RealmError> {
        do {
            try self.commitWrite()
            return .success(())
        } catch {
            log.error(error)
            BasicController.errorThrown?(error)
            return .failure(.writeError)
        }
    }
}

public class BasicController {

    public static var errorThrown: ((Error) -> Void)?
    
    // MARK: Initialization

    public enum Kind {
        case local, sync(SyncUser)
    }
    
    public let kind: Kind
    private let config: Realm.Configuration
    private var realm: Result<Realm, RealmError> {
        do {
            return try .success(Realm(configuration: self.config))
        } catch {
            log.error(error)
            type(of: self).errorThrown?(error)
            return .failure(.loadError)
        }
    }

    public class func new(of kind: Kind) -> Result<BasicController, RealmError> {
        do {
            let bc = try BasicController(kind: kind)
            return .success(bc)
        } catch {
            self.errorThrown?(error)
            return .failure(.createError)
        }
    }

    private init(kind: Kind) throws {
        self.kind = kind
        var realmConfig = Realm.Configuration()
        realmConfig.schemaVersion = 14
        realmConfig.objectTypes = [ReminderVessel.self, Reminder.self, ReminderPerform.self]
        switch kind {
        case .local:
            try type(of: self).createLocalRealmDirectoryIfNeeded()
            try type(of: self).copyRealmFromBundleIfNeeded()
            realmConfig.fileURL = type(of: self).localRealmFile
        case .sync(let user):
            let url = user.realmURL(withAppName: "WaterMeBasic")
            realmConfig.syncConfiguration = SyncConfiguration(user: user, realmURL: url, enableSSLValidation: true)
        }
        self.config = realmConfig
    }
    
    // MARK: WaterMeClient API

    public var userDidPerformReminder: (() -> Void)?

    public func allVessels() -> Result<AnyRealmCollection<ReminderVessel>, RealmError> {
        return self.realm.map() { realm in
            let kp = #keyPath(ReminderVessel.displayName)
            let collection = realm.objects(ReminderVessel.self).sorted(byKeyPath: kp)
            return AnyRealmCollection(collection)
        }
    }

    public func allReminders(sorted: Reminder.SortOrder = .nextPerformDate,
                             ascending: Bool = true) -> Result<AnyRealmCollection<Reminder>, RealmError> {
        return self.realm.map({ AnyRealmCollection($0.objects(Reminder.self).sorted(byKeyPath: sorted.keyPath, ascending: ascending)) })
    }

    public func reminders(in section: Reminder.Section,
                          sorted: Reminder.SortOrder = .nextPerformDate,
                          ascending: Bool = true) -> Result<AnyRealmCollection<Reminder>, RealmError>
    {
        return self.realm.map() { realm in
            let range = section.dateInterval
            let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(Reminder.nextPerformDate)),
                                      rightExpression: NSExpression(forConstantValue: range.start),
                                      modifier: .direct,
                                      type: .greaterThanOrEqualTo),
                NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(Reminder.nextPerformDate)),
                                      rightExpression: NSExpression(forConstantValue: range.end),
                                      modifier: .direct,
                                      type: .lessThan)
                ])
            if case .late = section {
                let nilCheck = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: #keyPath(Reminder.nextPerformDate)),
                                      rightExpression: NSExpression(forConstantValue: nil),
                                      modifier: .direct,
                                      type: .equalTo)
                let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [nilCheck, andPredicate])
                let collection = realm.objects(Reminder.self).filter(orPredicate).sorted(byKeyPath: sorted.keyPath, ascending: ascending)
                return AnyRealmCollection(collection)
            } else {
                let collection = realm.objects(Reminder.self).filter(andPredicate).sorted(byKeyPath: sorted.keyPath, ascending: ascending)
                return AnyRealmCollection(collection)
            }
        }
    }

    public func appendNewPerformToReminders(with identifiers: [Reminder.Identifier]) -> Result<Void, RealmError> {
        let result = self.reminders(matching: identifiers).flatMap({ self.appendNewPerform(to: $0) })
        self.userDidPerformReminder?()
        return result
    }

    public func reminder(matching identifier: Reminder.Identifier) -> Result<Reminder, RealmError> {
        return self.realm.flatMap() { realm -> Result<Reminder, RealmError> in
            guard let reminder = realm.object(ofType: Reminder.self, forPrimaryKey: identifier.reminderIdentifier)
                else { return .failure(.objectDeleted) }
            return .success(reminder)
        }
    }

    internal func reminders(matching identifiers: [Reminder.Identifier]) -> Result<[Reminder], RealmError> {
        return self.realm.map() { realm in
            return identifiers.flatMap({ realm.object(ofType: Reminder.self, forPrimaryKey: $0.reminderIdentifier) })
        }
    }

    internal func appendNewPerform(to reminders: [Reminder]) -> Result<Void, RealmError> {
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            for reminder in reminders {
                // append the perform
                let newPerform = ReminderPerform()
                reminder.performed.append(newPerform)
                reminder.recalculateNextPerformDate(comparisonPerform: newPerform)
                // perform bloops to force notification firing
                reminder.vessel?.bloop = !(reminder.vessel?.bloop ?? true)
            }
            return realm.waterMe_commitWrite()
        }
    }
    
    public func newReminder(for vessel: ReminderVessel) -> Result<Reminder, RealmError> {
        return self.realm.flatMap() { realm in
            let reminder = Reminder()
            realm.beginWrite()
            realm.add(reminder)
            vessel.reminders.append(reminder)
            return realm.waterMe_commitWrite().map({ reminder })
        }
    }
    
    public func newReminderVessel(displayName: String? = nil, icon: ReminderVessel.Icon? = nil, reminders: [Reminder]? = nil) -> Result<ReminderVessel, RealmError> {
        return self.realm.flatMap() { realm in
            let v = ReminderVessel()
            if let displayName = displayName?.leadingTrailingWhiteSpaceTrimmedNonEmptyString { // make sure the string is not empty
                v.displayName = displayName
            }
            if let icon = icon {
                v.icon = icon
            }
            if let reminders = reminders, reminders.isEmpty == false {
                v.reminders.append(objectsIn: reminders)
            } else {
                // enforce at least one reminder rule
                let reminder = Reminder()
                v.reminders.append(reminder)
            }
            realm.beginWrite()
            realm.add(v)
            return realm.waterMe_commitWrite().map({ v })
        }
    }
    
    public func update(displayName: String? = nil, icon: ReminderVessel.Icon? = nil, in vessel: ReminderVessel) -> Result<Void, RealmError> {
        guard vessel.isInvalidated == false else { return .failure(.objectDeleted) }
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            if let displayName = displayName {
                // make sure the string is not empty. If it is empty, set it to NIL
                vessel.displayName = displayName.leadingTrailingWhiteSpaceTrimmedNonEmptyString
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
    
    public func update(kind: Reminder.Kind? = nil, interval: Int? = nil, note: String? = nil, in reminder: Reminder) -> Result<Void, RealmError> {
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
                reminder.note = note.leadingTrailingWhiteSpaceTrimmedNonEmptyString
            }
            // trigger bloops so notifications fire
            reminder.vessel?.bloop = !(reminder.vessel?.bloop ?? true)
            for perform in reminder.performed {
                perform.bloop = !perform.bloop
            }
            return realm.waterMe_commitWrite()
        }
    }

    public func coreDataMigration(vesselName: String?,
                                  vesselImage: UIImage?,
                                  vesselEmoji: String?,
                                  reminderInterval: NSNumber?,
                                  reminderLastPerformDate: Date?) -> Result<Void, RealmError>
    {
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            let vessel = ReminderVessel()
            vessel.displayName = vesselName
            vessel.icon = ReminderVessel.Icon(rawImage: vesselImage, emojiString: vesselEmoji)
            let reminder = Reminder()
            reminder.interval = reminderInterval?.intValue ?? -1
            if let lastPerformDate = reminderLastPerformDate {
                let performed = ReminderPerform()
                performed.date = lastPerformDate
                reminder.performed.append(performed)
                reminder.recalculateNextPerformDate()
            }
            vessel.reminders.append(reminder)
            realm.add(vessel)
            return realm.waterMe_commitWrite()
        }
    }
        
    public func delete(vessel: ReminderVessel) -> Result<Void, RealmError> {
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            self.delete(vessel: vessel, inOpenRealm: realm)
            return realm.waterMe_commitWrite()
        }
    }
    
    private func delete(vessel: ReminderVessel, inOpenRealm realm: Realm) {
        for reminder in vessel.reminders {
            self.delete(reminder: reminder, inOpenRealm: realm)
        }
        realm.delete(vessel)
    }
        
    public func delete(reminder: Reminder) -> Result<Void, RealmError> {
        if let vessel = reminder.vessel, vessel.reminders.count <= 1 {
            return .failure(.unableToDeleteLastReminder) 
        }
        return self.realm.flatMap() { realm in
            realm.beginWrite()
            self.delete(reminder: reminder, inOpenRealm: realm)
            return realm.waterMe_commitWrite()
        }
    }
    
    private func delete(reminder: Reminder, inOpenRealm realm: Realm) {
        for perform in reminder.performed {
            realm.delete(perform)
        }
        realm.delete(reminder)
    }
}

extension BasicController {
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

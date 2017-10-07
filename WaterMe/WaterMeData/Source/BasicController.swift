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
            return .failure(.writeError)
        }
    }
}

public class BasicController {
    
    // MARK: Initialization
    
    public class var localRealmExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.localRealmFile.path)
        return exists
    }

    public enum Kind {
        case local, sync(SyncUser)
    }
    
    public let kind: Kind
    private let config: Realm.Configuration
    private var realm: Result<Realm, RealmError> {
        do {
            return try .success(Realm(configuration: self.config))
        } catch {
            return .failure(.loadError)
        }
    }
    
    public init(kind: Kind) {
        self.kind = kind
        var realmConfig = Realm.Configuration()
        realmConfig.schemaVersion = 10
        realmConfig.objectTypes = [ReminderVessel.self, Reminder.self, ReminderPerform.self]
        switch kind {
        case .local:
            try! type(of: self).createLocalRealmDirectoryIfNeeded()
            realmConfig.fileURL = type(of: self).localRealmFile
        case .sync(let user):
            let url = user.realmURL(withAppName: "WaterMeBasic")
            realmConfig.syncConfiguration = SyncConfiguration(user: user, realmURL: url, enableSSLValidation: true)
        }
        self.config = realmConfig
    }
    
    private class var localRealmDirectory: URL {
        let appsupport = FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        let url = appsupport.appendingPathComponent("WaterMe", isDirectory: true).appendingPathComponent("Free", isDirectory: true)
        return url
    }
    
    private class var localRealmFile: URL {
        return self.localRealmDirectory.appendingPathComponent("Realm.realm", isDirectory: false)
    }
    
    private class func createLocalRealmDirectoryIfNeeded() throws {
        if self.localRealmExists == false {
            try FileManager.default.createDirectory(at: self.localRealmDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    // MARK: WaterMeClient API
    
    public func allVessels() -> Result<AnyRealmCollection<ReminderVessel>, RealmError> {
        return self.realm.map() { realm in
            let kp = #keyPath(ReminderVessel.displayName)
            let collection = realm.objects(ReminderVessel.self).sorted(byKeyPath: kp)
            return AnyRealmCollection(collection)
        }
    }
    
    public func newReminder(for vessel: ReminderVessel) -> Result<Reminder, RealmError> {
        let realmResult = self.realm
        guard case .success(let realm) = realmResult else { return .failure(realmResult.error!) }
        let reminder = Reminder()
        realm.beginWrite()
        realm.add(reminder)
        vessel.reminders.append(reminder)
        let writeResult = realm.waterMe_commitWrite()
        return writeResult.map({ reminder })
    }
    
    public func newReminderVessel(displayName: String? = nil, icon: ReminderVessel.Icon? = nil, reminders: [Reminder]? = nil) -> Result<ReminderVessel, RealmError> {
        let realmResult = self.realm
        guard case .success(let realm) = realmResult else { return .failure(realmResult.error!) }
        let v = ReminderVessel()
        if let displayName = displayName?.leadingTrailingWhiteSpaceTrimmedNonEmptyString { // make sure the string is not empty
            v.displayName = displayName
        }
        if let icon = icon {
            v.icon = icon
        }
        if let reminders = reminders {
            v.reminders.append(objectsIn: reminders)
        }
        realm.beginWrite()
        realm.add(v)
        let writeResult = realm.waterMe_commitWrite()
        return writeResult.map({ v })
    }
    
    public func update(displayName: String? = nil, icon: ReminderVessel.Icon? = nil, in vessel: ReminderVessel) -> Result<Void, RealmError> {
        guard vessel.isInvalidated == false else { return .failure(.objectDeleted) }
        let realmResult = self.realm
        guard case .success(let realm) = realmResult else { return .failure(realmResult.error!) }
        realm.beginWrite()
        if let displayName = displayName {
            // make sure the string is not empty. If it is empty, set it to NIL
            vessel.displayName = displayName.leadingTrailingWhiteSpaceTrimmedNonEmptyString
        }
        if let icon = icon {
            vessel.icon = icon
        }
        let writeResult = realm.waterMe_commitWrite()
        return writeResult
    }
    
    public func update(kind: Reminder.Kind? = nil, interval: Int? = nil, note: String? = nil, in reminder: Reminder) -> Result<Void, RealmError> {
        guard reminder.isInvalidated == false else { return .failure(.objectDeleted) }
        let realmResult = self.realm
        guard case .success(let realm) = realmResult else { return .failure(realmResult.error!) }
        realm.beginWrite()
        if let kind = kind {
            reminder.kind = kind
        }
        if let interval = interval {
            reminder.interval = interval
        }
        if let note = note {
            // make sure the string is not empty. If it is empty, set it to blank string
            reminder.note = note.leadingTrailingWhiteSpaceTrimmedNonEmptyString
        }
        let writeResult = realm.waterMe_commitWrite()
        return writeResult
    }
        
    public func delete(vessel: ReminderVessel) -> Result<Void, RealmError> {
        let realmResult = self.realm
        guard case .success(let realm) = realmResult else { return .failure(realmResult.error!) }
        realm.beginWrite()
        self.delete(vessel: vessel, inOpenRealm: realm)
        let writeResult = realm.waterMe_commitWrite()
        return writeResult
    }
    
    private func delete(vessel: ReminderVessel, inOpenRealm realm: Realm) {
        for reminder in vessel.reminders {
            self.delete(reminder: reminder, inOpenRealm: realm)
        }
        realm.delete(vessel)
    }
        
    public func delete(reminder: Reminder) -> Result<Void, RealmError> {
        let realmResult = self.realm
        guard case .success(let realm) = realmResult else { return .failure(realmResult.error!) }
        realm.beginWrite()
        self.delete(reminder: reminder, inOpenRealm: realm)
        let writeResult = realm.waterMe_commitWrite()
        return writeResult
    }
    
    private func delete(reminder: Reminder, inOpenRealm realm: Realm) {
        for perform in reminder.performed {
            realm.delete(perform)
        }
        realm.delete(reminder)
    }
}

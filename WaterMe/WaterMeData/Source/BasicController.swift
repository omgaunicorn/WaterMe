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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import RealmSwift

public protocol HasBasicController {
    var basicRC: BasicController? { get set }
}

public extension HasBasicController {
    public mutating func configure(with basicRC: BasicController?) {
        guard let basicRC = basicRC else { return }
        self.basicRC = basicRC
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
    public var realm: Realm {
        return try! Realm(configuration: self.config)
    }
    
    public init(kind: Kind) {
        self.kind = kind
        var realmConfig = Realm.Configuration()
        realmConfig.schemaVersion = 5
        realmConfig.objectTypes = [ReminderVessel.self]
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
    
    public func allVessels() -> AnyRealmCollection<ReminderVessel> {
        let realm = self.realm
        let vessels = realm.objects(ReminderVessel.self).sorted(byKeyPath: #keyPath(ReminderVessel.displayName))
        return AnyRealmCollection(vessels)
    }
    
    public func newReminderVessel(displayName: String, icon: ReminderVessel.Icon, kind: ReminderVessel.Kind = .plant) {
        let realm = self.realm
        let vessel = ReminderVessel()
        vessel.displayName = displayName
        vessel.kind = kind
        vessel.icon = icon
        realm.beginWrite()
        realm.add(vessel)
        try! realm.commitWrite()
    }
    
    public func delete(vessel: ReminderVessel) {
        guard vessel.isInvalidated == false else { return }
        let realm = self.realm
        realm.beginWrite()
        realm.delete(vessel)
        try! realm.commitWrite()
    }
}

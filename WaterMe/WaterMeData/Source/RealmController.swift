//
//  RealmController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/15/17.
//
//

import RealmSwift

public class RealmController {
    
    public enum Kind {
        case local, synced(SyncUser)
    }
    
    public static var localRealmExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.localRealmDirectory.path)
        return exists
    }
    
    private static let localRealmDirectory: URL = {
        let appsupport = FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        let url = appsupport.appendingPathComponent("WaterMe", isDirectory: true).appendingPathComponent("FreeEdition", isDirectory: true)
        return url
    }()
    
    public let kind: Kind
    private let realmURL: URL
    
    public var realm: Realm {
        var config = Realm.Configuration()
        config.schemaVersion = 1
        
        switch self.kind {
        case .local:
            config.fileURL = self.realmURL
            if RealmController.localRealmExists == false {
                try! FileManager.default.createDirectory(at: RealmController.localRealmDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            let realm = try! Realm(configuration: config)
            return realm
        case .synced(let user):
            fatalError()
        }
    }
    
    public init(kind: Kind) {
        self.kind = kind
        switch kind {
        case .local:
            self.realmURL = RealmController.localRealmDirectory.appendingPathComponent("Realm.realm", isDirectory: false)
        case .synced(let user):
            fatalError()
        }
    }
    
}

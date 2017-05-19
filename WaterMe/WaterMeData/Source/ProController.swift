//
//  ProController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/18/17.
//
//

import RealmSwift

public class ProController {
    
    private static let objectTypes: [Object.Type] = []
    
    private let config: Realm.Configuration
    public var realm: Realm {
        return try! Realm(configuration: self.config)
    }
    
    public init(user: SyncUser) {
        var realmConfig = Realm.Configuration()
        let url = user.realmURL(withAppName: "WaterMePro")
        realmConfig.syncConfiguration = SyncConfiguration(user: user, realmURL: url, enableSSLValidation: true)
        realmConfig.schemaVersion = RealmSchemaVersion
        realmConfig.objectTypes = type(of: self).objectTypes
        self.config = realmConfig
    }
}

//
//  RealmController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/15/17.
//
//

import CloudKit
import RealmSwift

public protocol HasRealmControllers {
    
}

public class RealmController {
    
    public let kind: Kind
    private let realmConfig: Realm.Configuration
    
    public var realm: Realm {
        switch self.kind {
        case .local:
            try! type(of: self).createLocalRealmDirectoryIfNeeded()
            let realm = try! Realm(configuration: self.realmConfig)
            return realm
        case .basic(let user), .pro(let user):
            let realm = try! Realm(configuration: self.realmConfig)
            return realm
        }
    }
    
    public init(kind: Kind) {
        self.kind = kind
        self.realmConfig = kind.configuration
    }
    
}

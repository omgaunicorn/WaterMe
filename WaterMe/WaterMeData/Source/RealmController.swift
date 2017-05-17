//
//  RealmController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/15/17.
//
//

import CloudKit
import RealmSwift

public protocol HasRealmControllers: class {
    var basicRealmController: RealmController! { get set }
    var proRealmController: RealmController? { get set }
}

public extension HasRealmControllers {
    public func configure(withBasic basic: RealmController?, andPro pro: RealmController?) {
        if let basic = basic {
            switch basic.kind {
            case .basic, .local:
                self.basicRealmController = basic
            case .pro:
                fatalError("Pro RealmController passed in as Non-Pro Controller")
            }
        }
        if let pro = pro {
            switch pro.kind {
            case .pro:
                self.proRealmController = pro
            case .local, .basic:
                fatalError("Non-Pro RealmController passed in as Pro Controller")
            }
        }
    }
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

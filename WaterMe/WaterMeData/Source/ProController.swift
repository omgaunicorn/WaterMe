//
//  ProController.swift
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

public protocol HasProController {
    var proRC: ProController? { get set }
}

public extension HasProController {
    public mutating func configure(with proRC: ProController?) {
        guard let proRC = proRC else { return }
        self.proRC = proRC
    }
}

public class ProController {
    /*
    public let config: Realm.Configuration
    public var realm: Realm {
        return try! Realm(configuration: self.config)
    }
    
    public init(user: SyncUser) {
        var realmConfig = Realm.Configuration()
        realmConfig.schemaVersion = 4
        realmConfig.objectTypes = []
        let url = user.realmURL(withAppName: "WaterMePro")
        realmConfig.syncConfiguration = SyncConfiguration(user: user, realmURL: url, enableSSLValidation: true)
        self.config = realmConfig
    }
 */
}

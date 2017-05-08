//
//  Test.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import CloudKit
import RealmSwift

public class iCloudLogin {
    public class func dontUseYet() {
        let container = CKContainer.default()
        container.fetchUserRecordID { id, error in
            guard let id = id else {
                print(error!)
                return
            }
            
            let server = PrivateKeys.kRealmServer
            let credential = SyncCredentials.cloudKit(token: id.recordName)
            SyncUser.logIn(with: credential, server: server) { user, error in
                print(user)
                print(error)
                user?.logOut()
            }
        }
    }
}

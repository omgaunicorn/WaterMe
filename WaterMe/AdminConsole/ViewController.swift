//
//  ViewController.swift
//  AdminConsole
//
//  Created by Jeffrey Bergier on 5/18/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import RealmSwift
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = SyncUser.current {
            self.doRealm(user: user)
        } else {
            let credentials = SyncCredentials.usernamePassword(username: PrivateKeys.kRealmAdminLogin, password: PrivateKeys.kRealmAdminPassword, register: false)
            SyncUser.logIn(with: credentials, server: WaterMeData.PrivateKeys.kRealmServer) { user, error in
                DispatchQueue.main.async {
                    guard let user = user else { print(error!); return; }
                    self.doRealm(user: user)
                }
            }
        }
    }
    
    var realmController: RealmController?

    private func doRealm(user: SyncUser) {
        let kind = RealmController.Kind.basic(user)
        let realmController = RealmController(kind: kind, overrideUserPath: "a585e812c45049b8aaaba33797ab7767/")
        self.realmController = realmController
        realmController.receiptChanged = { receipt in
            print(receipt)
        }
    }
}


//
//  RouterViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import RealmSwift
import CloudKit
import WaterMeData
import WaterMeStore
import UIKit

// Eventual Boot Sequence
/*
 1. Check for Core Data database
    YES - migrate to free realm, present new subscription options
    NO - Go to 2
 
 2. Check realm for icloud logged in user
    YES - Check the Basic Realm receipt object to see if there is a realm for Pro photo sync
        YES - Load pro data assuming the user is Pro
        NO - Load app assuming user has Basic cloud sync
    NO - Go to 3
 
 3. Check if there is a local realm on disk
    YES - Assume user is free and load app
    NO - Go to 4
 
 4. Check if there is a receipt
    NO - Assume new free user - create local realm
    YES - Go to 5
 
 5. Read receipt and check for subscription
    YES (subscription present) - Assume receipt is valid, configure realm for subscription level
    NO (subscription not present) - Assume new user - setup for local free realm
*/

class RouterViewController: UIViewController, HasRealmControllers {
    
    class func newVC(basicRealmController: RealmController? = nil, proRealmController: RealmController? = nil) -> RouterViewController {
        let sb = UIStoryboard(name: "Router", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! RouterViewController
        vc.configure(withBasic: basicRealmController, andPro: proRealmController)
        return vc
    }
    
    var basicRealmController: RealmController!
    var proRealmController: RealmController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.basicRealmController == nil {
            self.startBootSequence()
        }
    }
    
    private func startBootSequence() {
        // Eventual Boot Sequence
        /*
         1. Check for Core Data database
            YES - migrate to free realm, present new subscription options
            NO - Go to 2
         
         2. Check realm for icloud logged in user
            YES - Check the Basic Realm receipt object to see if there is a realm for Pro photo sync
                YES - Load pro data assuming the user is Pro
                NO - Load app assuming user has Basic cloud sync
            NO - Go to 3
         
         3. Check if there is a local realm on disk
            YES - Assume user is free and load app
            NO - Go to 4
         
         4. Check if there is a receipt
            NO - Assume new free user - create local realm
            YES - Go to 5
         
         5. Read receipt and check for subscription
            YES (subscription present) - Assume receipt is valid, configure realm for subscription level
            NO (subscription not present) - Assume new user - setup for local free realm
        */
        
        if let alreadyLoggedInUser = RealmController.loggedInUser {
            let basicRC = RealmController(kind: .basic(alreadyLoggedInUser))
            var proRC: RealmController?
            // if basicRC.reciept.pro == true {
            //    proRC = RealmController(kind: .pro(alreadyLoggedInUser))
            // }
            self.configure(withBasic: basicRC, andPro: proRC)
        } else if RealmController.localRealmExists == true {
            let freeRC = RealmController(kind: .local)
            self.configure(withBasic: freeRC, andPro: nil)
        } else {
            // check receipt
            let freeRC = RealmController(kind: .local)
            self.configure(withBasic: freeRC, andPro: nil)
        }
    }
    
    @IBAction private func premiumButtonTapped(_ sender: NSObject?) {
        let sender = sender as? UIControl
        sender?.isEnabled = false
        let sl = SubscriptionLoader()
        sl.start() { _ in
            sender?.isEnabled = true
            let vc = SubscriptionChoiceViewController.newVC(subscriptionLoader: sl)
            let navVC = UINavigationController(rootViewController: vc)
            self.show(navVC, sender: sender ?? self)
        }
    }
    
    @IBAction private func localRealm(_ sender: NSObject?) {
        print("Local Realm Exists: \(RealmController.localRealmExists)")
        print("LoggedIn User: \(RealmController.loggedInUser)")
        let rc = RealmController(kind: .local)
        print(rc)
        print(rc.realm)
    }
    
    @IBAction private func syncedRealm(_ sender: NSObject?) {
        print("Local Realm Exists: \(RealmController.localRealmExists)")
        print("LoggedIn User: \(RealmController.loggedInUser)")
        if let user = RealmController.loggedInUser {
            let proRC = RealmController(kind: .pro(user))
            let basicRC = RealmController(kind: .basic(user))
            print("Already Logged In")
            print("ProRC: \(proRC)")
            print("ProRC Realm: \(proRC.realm)")
            print("BasicRC: \(basicRC)")
            print("BasicRC Realm: \(basicRC.realm)")
        } else {
            print("Getting CKToken")
            CKContainer.default().token() { result in
                switch result {
                case .error(let error):
                    print("CloudKitError: \(error)")
                case .success(let token):
                    print("Logging into Realm")
                    SyncUser.cloudKitUser(with: token) { result in
                        switch result {
                        case .error(let error):
                            print("Realm Error: \(error)")
                        case .success(let user):
                            print("Logged In")
                            let proRC = RealmController(kind: .pro(user))
                            let basicRC = RealmController(kind: .basic(user))
                            print("ProRC: \(proRC)")
                            print("ProRC Realm: \(proRC.realm)")
                            print("BasicRC: \(basicRC)")
                            print("BasicRC Realm: \(basicRC.realm)")
                        }
                    }
                }
            }
        }
    }
}

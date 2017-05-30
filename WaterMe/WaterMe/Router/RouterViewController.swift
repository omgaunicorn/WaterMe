//
//  RouterViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
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

import TPInAppReceipt
import RealmSwift
import CloudKit
import WaterMeData
import WaterMeStore
import UIKit

class RouterViewController: UIViewController {
    
    class func newVC() -> RouterViewController {
        let sb = UIStoryboard(name: "Router", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! RouterViewController
        return vc
    }
    
    var receipt: ReceiptController?
    var basic: BasicController?
    var pro: ProController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.basic == nil {
            self.startBootSequence()
        }
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: true)
    }
    
    @objc private func timerFired(_ timer: NSObject?) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let receiptWatcher = appDelegate.receiptWatcher
        
        let result = receiptWatcher.currentSubscription
        print(result)
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
        
        if let user = SyncUser.current {
            let receiptRC = ReceiptController(user: user)
            self.receipt = receiptRC
            let receipt = receiptRC.receipt
            let productID = receipt.server_productID ?? receipt.client_productID ?? "NaN"
            guard let level = Level(productID: productID) else { return }
            switch level {
            case .pro:
                let proRC = ProController(user: user)
                self.pro = proRC
                fallthrough
            case .basic:
                let basicRC = BasicController(kind: .sync(user))
                self.basic = basicRC
            }

        } else if BasicController.localRealmExists == true {
            let freeRC = BasicController(kind: .local)
            self.basic = freeRC
            self.pro = nil
        } else {
            // check receipt
//            let appD = UIApplication.shared.delegate as! AppDelegate
//            let mon = appD.receiptMonitor
//            if mon.receiptChanged == true {
//                mon.updateReceipt()
//            }
//            let level = mon.purchased.level
//            print(level)
//            switch level {
//            case .free:
//                // auto-configure free account
////                let freeRC = RealmController(kind: .local)
////                self.configure(withBasic: freeRC, andPro: nil)
//                break
//            case .basic, .pro:
//                // present login / migration screen
//                break
//            }
        }
    }
    
    @IBAction private func premiumButtonTapped(_ sender: NSObject?) {
        let sender = sender as? UIControl
        sender?.isEnabled = false
        let sl = UnpurchasedSubscriptionDownloader()
        sl.start() { _ in
            sender?.isEnabled = true
            let vc = SubscriptionChoiceViewController.newVC(subscriptionLoader: sl)
            let navVC = UINavigationController(rootViewController: vc)
            self.show(navVC, sender: sender ?? self)
        }
    }
    
    @IBAction private func localRealm(_ sender: NSObject?) {
        print("Local Realm Exists: \(BasicController.localRealmExists)")
        print("LoggedIn User: \(SyncUser.current)")
        let rc = BasicController(kind: .local)
        print(rc)
        print(rc.realm.schema)
        self.basic = rc
        self.receipt = nil
        self.pro = nil
    }
    
    @IBAction private func syncedRealm(_ sender: NSObject?) {
        print("Local Realm Exists: \(BasicController.localRealmExists)")
        print("LoggedIn User: \(SyncUser.current)")
        if let user = SyncUser.current {
            let receipt = ReceiptController(user: user)
            let basic = BasicController(kind: .sync(user))
            let pro = ProController(user: user)
            self.basic = basic
            self.pro = pro
            self.receipt = receipt
            print("Already Logged In")
            print("Basic Schema: \(basic.realm.schema)")
            print("Receipt Schema: \(receipt.realm.schema)")
            print("Pro Schema: \(pro.realm.schema)")
        } else {
            print("Getting CKToken")
            CKContainer.default().token() { result in
                switch result {
                case .failure(let error):
                    print("CloudKitError: \(error)")
                case .success(let token):
                    print("Logging into Realm")
                    SyncUser.cloudKitUser(with: token) { result in
                        switch result {
                        case .failure(let error):
                            print("Realm Error: \(error)")
                        case .success(let user):
                            print("Logged In")
                            let receipt = ReceiptController(user: user)
                            let basic = BasicController(kind: .sync(user))
                            let pro = ProController(user: user)
                            self.basic = basic
                            self.pro = pro
                            self.receipt = receipt
                            print("Basic Schema: \(basic.realm.schema)")
                            print("Receipt Schema: \(receipt.realm.schema)")
                            print("Pro Schema: \(pro.realm.schema)")
                        }
                    }
                }
            }
        }
    }
}

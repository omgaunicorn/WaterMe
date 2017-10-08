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
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
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
    
    private var doOnViewDidAppear = [() -> Void]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startBootSequence()
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
        
        if let user = SyncUser.current, let subscription = AppDelegate.shared.receiptWatcher.effectiveSubscription {
            switch subscription.level {
            case .pro:
                let proRC = ProController(user: user)
                fallthrough
            case .basic:
                let basicRC = BasicController(kind: .sync(user))
            }
        } else if BasicController.localRealmExists == true {
            let freeRC = BasicController(kind: .local)
            let vc = ReminderVesselTabViewController(basicController: freeRC, proController: nil)
            self.doOnViewDidAppear.append({ self.presentOnTop(vc, animated: true, completion: nil) })
        } else {
            log.severe("We're in a first run experience here")
            log.severe("for now we're setting up a local basic experience")
            let freeRC = BasicController(kind: .local)
            let vc = ReminderVesselTabViewController(basicController: freeRC, proController: nil)
            self.doOnViewDidAppear.append({ self.presentOnTop(vc, animated: true, completion: nil) })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.doOnViewDidAppear.forEach({ $0() })
        self.doOnViewDidAppear = []
    }
    
    @IBAction private func premiumButtonTapped(_ sender: NSObject?) {
        let vc = SubscriptionChoiceViewController.newVC()
        let navVC = UINavigationController(rootViewController: vc)
        self.show(navVC, sender: sender ?? self)
    }
    
    @IBAction private func localRealm(_ sender: NSObject?) {
        print("Need to create local realm")
    }
    
    @IBAction private func syncedRealm(_ sender: NSObject?) {
        print("Need to Login")
    }
}

//
//  SubscriptionMigrationViewController.swift
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

import WaterMeStore
import UIKit

class SubscriptionMigrationViewController: UIViewController, HasUnpurchasedSubscriptionPurchaseType {
    
    class func newVC(subscriptionPurchaser: UnpurchasedSubscriptionPurchaseType) -> SubscriptionMigrationViewController {
        let sb = UIStoryboard(name: "SubscriptionMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! SubscriptionMigrationViewController
        vc.configure(with: subscriptionPurchaser)
        return vc
    }
    
    @IBOutlet private weak var tempLabel: UILabel?
    
    var subscriptionPurchaser: UnpurchasedSubscriptionPurchaseType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(self.subscriptionPurchaser != nil, "A Subscription Purchaser must be set.")
        
        // configure my vc
        self.title = "Migration"
        
        // configure the label
        self.tempLabel?.text = self.subscriptionPurchaser.subscription.localizedTitle
    }
    
    @IBAction private func tempStartBuyProcess(_ sender: NSObject?) {
        self.subscriptionPurchaser.start() { result in
            switch result {
            case .deferred:
                self.tempLabel?.text = "Deferred, you big baby"
            case .failed(let error, _):
                self.tempLabel?.text = error.localizedDescription
            case .success:
                self.tempLabel?.text = "Purchased!"
            }
        }
    }
}

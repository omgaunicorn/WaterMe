//
//  SubscriptionMigrationViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
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

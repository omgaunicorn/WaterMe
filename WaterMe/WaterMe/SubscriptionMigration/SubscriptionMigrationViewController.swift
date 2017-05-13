//
//  SubscriptionMigrationViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionMigrationViewController: UIViewController, HasSubscriptionPurchaseType {
    
    class func newVC(subscriptionPurchaser: SubscriptionPurchaseType) -> SubscriptionMigrationViewController {
        let sb = UIStoryboard(name: "SubscriptionMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! SubscriptionMigrationViewController
        vc.configure(with: subscriptionPurchaser)
        return vc
    }
    
    @IBOutlet private weak var tempLabel: UILabel?
    
    var subscriptionPurchaser: SubscriptionPurchaseType!
    
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
                print("deferred")
            case .failed(let error, _):
                print("failed with error: \(error)")
            case .success:
                print("yay!")
            }
        }
    }
}

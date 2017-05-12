//
//  SubscriptionMigrationViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionMigrationViewController: UIViewController, HasSubscriptionType {
    
    class func newVC(subscription: Subscription) -> SubscriptionMigrationViewController {
        let sb = UIStoryboard(name: "SubscriptionMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! SubscriptionMigrationViewController
        vc.configure(with: subscription)
        return vc
    }
    
    @IBOutlet private weak var tempLabel: UILabel?
    
    var subscription: Subscription!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure my vc
        self.title = "Migration"
        
        // configure the label
        self.tempLabel?.text = self.subscription.localizedTitle
    }
    
    @IBAction private func tempStartBuyProcess(_ sender: NSObject?) {
        print("Buy!")
    }
    
}

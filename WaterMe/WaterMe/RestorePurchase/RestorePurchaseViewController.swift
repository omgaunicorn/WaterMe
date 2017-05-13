//
//  RestorePurchaseViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/13/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class RestorePurchaseViewController: UIViewController, HasSubscriptionRestoreType {
    
    class func newVC(subscriptionRestorer: SubscriptionRestoreType? = nil) -> RestorePurchaseViewController {
        let sb = UIStoryboard(name: "RestorePurchase", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! RestorePurchaseViewController
        vc.configure(with: subscriptionRestorer)
        return vc
    }
    
    @IBOutlet private weak var tempLabel: UILabel?
    
    var subscriptionRestorer: SubscriptionRestoreType = SubscriptionRestorer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.title = "Restore Subscription"
    }
    
    @IBAction private func restoreButtonTapped(_ sender: NSObject?) {
        self.subscriptionRestorer.start() { result in
            switch result {
            case .success:
                self.tempLabel?.text = "Purchases Restored. Now need to analyze receipt"
            case .error(let error):
                self.tempLabel?.text = error.localizedDescription
            }
        }
    }
    
}

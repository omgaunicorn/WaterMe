//
//  RouterViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class RouterViewController: UIViewController {
    
    class func newVC() -> RouterViewController {
        let sb = UIStoryboard(name: "Router", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! RouterViewController
        return vc
    }
    
    @IBAction private func premiumButtonTapped(_ sender: NSObject?) {
        guard let sender = sender as? UIControl else { return }
        sender.isEnabled = false
        let sl = SubscriptionLoader()
        sl.start() { _ in
            let vc = SubscriptionChoiceViewController.newVC(subscriptionLoader: sl)
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true) {
                sender.isEnabled = true
            }
        }
    }
    
    @objc private func restorePurchases(_ sender: NSObject?) {
        print("Restore Purchases")
    }
}

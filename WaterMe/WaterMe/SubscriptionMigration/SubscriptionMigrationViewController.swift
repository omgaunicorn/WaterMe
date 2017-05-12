//
//  SubscriptionMigrationViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/11/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionMigrationViewController: UIViewController {
    
    class func newVC() -> SubscriptionMigrationViewController {
        let sb = UIStoryboard(name: "SubscriptionMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! SubscriptionMigrationViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
    }
    
}

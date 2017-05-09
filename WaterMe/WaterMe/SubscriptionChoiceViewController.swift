//
//  SubscriptionChoiceViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class SubscriptionChoiceViewController: UIViewController {
    
    class func newVC() -> SubscriptionChoiceViewController {
        let sb = UIStoryboard(name: "SubscriptionChoice", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! SubscriptionChoiceViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) Loaded")
    }
    
}

//
//  RestorePurchaseViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/13/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class RestorePurchaseViewController: UIViewController {
    
    class func newVC() -> RestorePurchaseViewController {
        let sb = UIStoryboard(name: "RestorePurchase", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! RestorePurchaseViewController
        return vc
    }
    
    @IBOutlet private weak var tempLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Restore Subscription"
    }
    
    @IBAction private func restoreButtonTapped(_ sender: NSObject?) {
        
    }
    
}

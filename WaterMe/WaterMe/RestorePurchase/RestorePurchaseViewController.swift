//
//  RestorePurchaseViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/13/17.
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
            case .failure(let error):
                self.tempLabel?.text = error.localizedDescription
            }
        }
    }
    
}

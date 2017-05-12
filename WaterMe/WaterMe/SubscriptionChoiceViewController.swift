//
//  SubscriptionChoiceViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionChoiceViewController: UIViewController, HasSubscriptionType {
    
    class func newVC(subscriptionLoader: SubscriptionLoaderType? = nil) -> UINavigationController {
        let sb = UIStoryboard(name: "SubscriptionChoice", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! SubscriptionChoiceViewController
        vc.configure(with: subscriptionLoader)
        return navVC
    }
    
    /*@IBOutlet*/ private weak var collectionViewController: SubscriptionChoiceCollectionViewController?
    @IBOutlet private weak var restoreBarButtonItem: UIBarButtonItem? {
        didSet {
            self.restoreBarButtonItem?.title = "Restore2"
        }
    }
    
    lazy var subscriptionLoader: SubscriptionLoaderType = SubscriptionLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populate children VC's
        self.collectionViewController = self.childViewControllers.first()
        
        // configure my vc
        self.title = "WaterMe Premium"
        
        // get the subscription information
        self.subscriptionLoader.start() { result in
            switch result {
            case .success(let results):
                self.collectionViewController?.data = results
            case .error:
                self.collectionViewController?.data = []
            }
            self.collectionViewController?.reload()
        }
    }
    
}

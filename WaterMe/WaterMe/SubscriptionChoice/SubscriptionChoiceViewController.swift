//
//  SubscriptionChoiceViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionChoiceViewController: UIViewController, HasSubscriptionLoaderType {
    
    class func newVC(subscriptionLoader: SubscriptionLoaderType? = nil) -> SubscriptionChoiceViewController {
        let sb = UIStoryboard(name: "SubscriptionChoice", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! SubscriptionChoiceViewController
        vc.configure(with: subscriptionLoader)
        return vc
    }
    
    /*@IBOutlet*/ private weak var collectionViewController: SubscriptionChoiceCollectionViewController?
    @IBOutlet private weak var restoreBarButtonItem: UIBarButtonItem? {
        didSet {
            self.restoreBarButtonItem?.title = "Restore"
        }
    }
    
    lazy var subscriptionLoader: SubscriptionLoaderType = SubscriptionLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populate children VC's
        self.collectionViewController = self.childViewControllers.first()
        
        // configure my vc
        self.title = "Premium"
        
        // register for events from the collection view controller
        self.collectionViewController?.subscriptionSelected = { [weak self] subscription in
            let vc = SubscriptionMigrationViewController.newVC(subscriptionPurchaser: SubscriptionPurchaser(itemToPurchase: subscription)!)
            self?.show(vc, sender: self)
        }
        
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

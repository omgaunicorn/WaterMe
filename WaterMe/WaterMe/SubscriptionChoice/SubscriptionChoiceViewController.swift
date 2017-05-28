//
//  SubscriptionChoiceViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionChoiceViewController: UIViewController, HasUnpurchasedSubscriptionDownloaderType {
    
    class func newVC(subscriptionLoader: UnpurchasedSubscriptionDownloaderType? = nil) -> SubscriptionChoiceViewController {
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
    
    lazy var subscriptionLoader: UnpurchasedSubscriptionDownloaderType = UnpurchasedSubscriptionDownloader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // populate children VC's
        self.collectionViewController = self.childViewControllers.first()
        
        // configure my vc
        self.title = "Premium"
        
        // register for events from the collection view controller
        self.collectionViewController?.subscriptionSelected = { [weak self] subscription in
            let purchaser = UnpurchasedSubscriptionPurchaser(itemToPurchase: subscription)!
            let vc = SubscriptionMigrationViewController.newVC(subscriptionPurchaser: purchaser)
            self?.show(vc, sender: self)
        }
        
        // get the subscription information
        self.subscriptionLoader.start() { result in
            switch result {
            case .success(let results):
                self.collectionViewController?.data = results
            case .failure:
                self.collectionViewController?.data = []
            }
            self.collectionViewController?.reload()
        }
    }
    
    @IBAction private func restorePurchases(_ sender: NSObject?) {
        let vc = RestorePurchaseViewController.newVC()
        self.show(vc, sender: sender ?? self)
    }
    
}

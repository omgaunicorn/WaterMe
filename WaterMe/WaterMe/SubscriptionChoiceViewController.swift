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
    
    class func newVC(subscriptionLoader: SubscriptionLoaderType? = nil) -> SubscriptionChoiceViewController {
        let sb = UIStoryboard(name: "SubscriptionChoice", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! SubscriptionChoiceViewController
        
        vc.configure(with: subscriptionLoader)
        
        return vc
    }
    
    /*@IBOutlet*/ private weak var collectionViewController: SubscriptionChoiceCollectionViewController?
    
    var subscriptionLoader: SubscriptionLoaderType = SubscriptionLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionViewController = self.childViewControllers.first()
        
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

//
//  SubscriptionChoiceCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class SubscriptionChoiceCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) Loaded")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! SubscriptionChoiceCollectionViewCell
        let model = SubscriptionLevel(rawValue: indexPath.row)!
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: floor(collectionView.bounds.size.height / 2))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = self.topParent.topLayoutGuide.length
        let bottomInset = self.topParent.bottomLayoutGuide.length
        self.collectionView?.contentInset.top = topInset
        self.collectionView?.contentInset.bottom = bottomInset
        self.collectionView?.scrollIndicatorInsets.top = topInset
        self.collectionView?.scrollIndicatorInsets.bottom = bottomInset
    }
}

fileprivate extension SubscriptionLevel {
    init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .free
        case 1:
            self = .basic
        case 2:
            self = .pro
        default:
            return nil
        }
    }
}

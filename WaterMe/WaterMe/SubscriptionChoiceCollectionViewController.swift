//
//  SubscriptionChoiceCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class SubscriptionChoiceCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var data: [Subscription] = []
    
    func reload() {
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SubscriptionChoiceCollectionViewCell.register(with: self.collectionView)
        print("\(type(of: self)) Loaded")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = SubscriptionChoiceCollectionViewCell.identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! SubscriptionChoiceCollectionViewCell
        cell.model = self.data[indexPath.row]
        return cell
    }
    
    let resizingCell = SubscriptionChoiceCollectionViewCell.newCell()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = self.data[indexPath.row]
        let width = collectionView.frame.size.width
        self.resizingCell.frame.size.width = width
        self.resizingCell.widthConstraint!.constant = width
        self.resizingCell.model = model
        self.resizingCell.layoutSubviews()
        let height = self.resizingCell.frame.size.height
        print(height)
        return CGSize(width: width, height: height)
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

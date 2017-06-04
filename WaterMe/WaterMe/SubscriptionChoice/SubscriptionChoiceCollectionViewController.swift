//
//  SubscriptionChoiceCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
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

class SubscriptionChoiceCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var data: [UnpurchasedSubscription] = []
    
    var subscriptionSelected: ((UnpurchasedSubscription) -> Void)?
    
    func reload() {
        self.collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SubscriptionChoiceCollectionViewCell.register(with: self.collectionView)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView?.deselectAllItems(animated: animated)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = SubscriptionChoiceCollectionViewCell.identifier
        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! SubscriptionChoiceCollectionViewCell
        cell.model = self.data[indexPath.row]
        return cell
    }
    
    private lazy var resizingCell: SubscriptionChoiceCollectionViewCell = {
        let cell = SubscriptionChoiceCollectionViewCell.newCell()
        cell.widthConstraint?.isActive = true
        return cell
    }()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = self.data[indexPath.row]
        let width = collectionView.frame.size.width
        self.resizingCell.model = model
        self.resizingCell.widthConstraint?.constant = width
        let newSize = self.resizingCell.contentView.systemLayoutSizeFitting(CGSize(width: width, height: 200))
        return CGSize(width: width, height: newSize.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.data[indexPath.row]
        self.subscriptionSelected?(model)
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

//
//  StandardCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/20/18.
//  Copyright © 2018 Saturday Apps.
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

import UIKit

class StandardCollectionViewController: UICollectionViewController {

    /// To be used by subclasses overriding `columnCountAndItemHeight` to help standardize rounding.
    class func columnCountAndItemHeight(withWidth width: CGFloat, columnCount: Int) -> (columnCount: Int, itemHeight: CGFloat) {
        let itemHeight = floor((width) / CGFloat(columnCount))
        return (columnCount, itemHeight)
    }

    var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    var columnCountAndItemHeight: (columnCount: Int, itemHeight: CGFloat) {
        return (2, 100)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.contentSizeCategoryDidChange(_:)),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Hacky workaround for RDAR:44727935
        // https://openradar.appspot.com/radar?id=4999954644860928
        self.userActivity?.needsSave = true
        self.userActivity?.becomeCurrent()
    }

    @objc private func contentSizeCategoryDidChange(_ aNotification: Any) {
        // TableViewControllers do this automatically
        // Whenever the text size is changed by the user, just reload the collection view
        // then all the cells get their attributed strings re-set
        self.collectionView?.reloadData()
    }

    /// Updates flow layout based on `columnCount` and `itemHeight` properties
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateFlowItemSize()
    }

    private func updateFlowItemSize() {
        let tuple = self.columnCountAndItemHeight
        let columnCount = CGFloat(tuple.columnCount)
        let itemHeight = tuple.itemHeight
        // calculate width of collectionView with insets accounted for
        let width = self.collectionView?.availableContentSize.width ?? 0
        // calculate column width based on usable width of collectionview
        let division = width / columnCount
        self.flow?.itemSize = CGSize(width: floor(division), height: itemHeight)
    }
}

class StandardTableViewController: UITableViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Hacky workaround for RDAR:44727935
        // https://openradar.appspot.com/radar?id=4999954644860928
        self.userActivity?.needsSave = true
        self.userActivity?.becomeCurrent()
    }
}

class StandardViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Hacky workaround for RDAR:44727935
        // https://openradar.appspot.com/radar?id=4999954644860928
        self.userActivity?.needsSave = true
        self.userActivity?.becomeCurrent()
    }
}

extension StandardViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return presentationLogic(with: traitCollection)
    }
}

extension StandardTableViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return presentationLogic(with: traitCollection)
    }
}

extension StandardCollectionViewController: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle
    {
        return presentationLogic(with: traitCollection)
    }
}

private func presentationLogic(with traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    /**
     Apple Docs:
     The new presentation style, which must be UIModalPresentationStyle.fullScreen, UIModalPresentationStyle.overFullScreen, UIModalPresentationStyle.formSheet, or UIModalPresentationStyle.none.
     If you do not implement this method or if you return an invalid style, the current presentation controller returns its preferred default style.
     */
    let invalidStyle = UIModalPresentationStyle(rawValue: -100)!
    let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
    return !isAccessibilityCategory ? invalidStyle : .overFullScreen
}

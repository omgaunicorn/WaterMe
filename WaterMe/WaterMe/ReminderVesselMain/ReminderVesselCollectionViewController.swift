//
//  ReminderVesselCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/31/17.
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

import Result
import WaterMeData
import RealmSwift
import UIKit

class ReminderVesselCollectionViewController: ContentSizeReloadCollectionViewController, HasBasicController {
    
    var vesselChosen: ((ReminderVessel) -> Void)?
        
    var basicRC: BasicController? {
        didSet {
            guard self.isViewLoaded else { return }
            self.hardReloadData()
        }
    }
    
    internal var data: Result<AnyRealmCollection<ReminderVessel>, RealmError>?
    private var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.register(ReminderVesselCollectionViewCell.nib, forCellWithReuseIdentifier: ReminderVesselCollectionViewCell.reuseID)
        self.flow?.minimumInteritemSpacing = 0
        self.hardReloadData()
    }
    
    private func hardReloadData() {
        self.notificationToken?.stop()
        self.notificationToken = nil
        self.data = nil
        
        guard let result = self.basicRC?.allVessels() else { return }
        switch result {
        case .failure:
            self.data = result
        case .success(let collection):
            self.notificationToken = collection.addNotificationBlock({ [weak self] changes in self?.dataChanged(changes) })
        }
    }
    
    private func dataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<ReminderVessel>>) {
        switch changes {
        case .initial(let data):
            self.data = .success(data)
            self.collectionView?.reloadData()
        case .update(_, deletions: let del, insertions: let ins, modifications: let mod):
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: ins.map({ IndexPath(row: $0, section: 0) }))
                self.collectionView?.deleteItems(at: del.map({ IndexPath(row: $0, section: 0) }))
                self.collectionView?.reloadItems(at: mod.map({ IndexPath(row: $0, section: 0) }))
            }, completion: nil)
        case .error(let error):
            log.error(error)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.value?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderVesselCollectionViewCell.reuseID, for: indexPath)
        if let vessel = self.data?.value?[indexPath.row], let cell = cell as? ReminderVesselCollectionViewCell {
            cell.configure(with: vessel)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vessel = self.data?.value?[indexPath.row] else { return }
        self.vesselChosen?(vessel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateFlowItemSize()
    }

    private func updateFlowItemSize() {
        let numberOfItemsPerRow: CGFloat
        let accessibility = UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory
        switch (self.view.traitCollection.horizontalSizeClass, accessibility) {
        case (.unspecified, _):
            assertionFailure("Hit a size class this VC was not expecting")
            fallthrough
        case (.regular, false):
            numberOfItemsPerRow = 4
        case (.regular, true):
            numberOfItemsPerRow = 2
        case (.compact, false):
            numberOfItemsPerRow = 2
        case (.compact, true):
            numberOfItemsPerRow = 1
        }
        let width: CGFloat = floor((self.collectionView?.bounds.width ?? 0) / numberOfItemsPerRow)
        self.flow?.itemSize = CGSize(width: width, height: width)
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
    
}

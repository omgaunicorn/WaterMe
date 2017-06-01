//
//  ReminderVesselCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/31/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import RealmSwift
import UIKit

class ReminderVesselCollectionViewController: UICollectionViewController, HasBasicController {
        
    var basicRC: BasicController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    private var data: AnyRealmCollection<ReminderVessel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.register(ReminderVesselCollectionViewCell.nib, forCellWithReuseIdentifier: ReminderVesselCollectionViewCell.reuseID)
        log.debug("")
    }
    
    private func hardReloadData() {
        self.notificationToken?.stop()
        self.notificationToken = nil
        self.data = nil
        
        let data = self.basicRC?.allVessels()
        self.notificationToken = data?.addNotificationBlock({ [weak self] changes in self?.dataChanged(changes) })
    }
    
    private func dataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<ReminderVessel>>) {
        switch changes {
        case .initial(let data):
            self.data = data
            self.collectionView?.reloadData()
        case .update(_, deletions: let del, insertions: let ins, modifications: let mod):
            self.collectionView?.reloadData()
        case .error(let error):
            log.error(error)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderVesselCollectionViewCell.reuseID, for: indexPath) as! ReminderVesselCollectionViewCell
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let top = self.topParent.topLayoutGuide.length
        let bottom = self.topParent.bottomLayoutGuide.length
        
        self.collectionView?.contentInset.top = top
        self.collectionView?.scrollIndicatorInsets.top = top
        self.collectionView?.contentInset.bottom = bottom
        self.collectionView?.scrollIndicatorInsets.bottom = bottom
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
    
}

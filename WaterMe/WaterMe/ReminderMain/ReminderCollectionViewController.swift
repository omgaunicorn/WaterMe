//
//  ReminderCollectionViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 08/10/17.
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
import RealmSwift
import WaterMeData
import UIKit

class ReminderCollectionViewController: ContentSizeReloadCollectionViewController, HasBasicController, HasProController {
    
    var proRC: ProController?
    var basicRC: BasicController?
    
    private var data: Result<AnyRealmCollection<ReminderVessel>, RealmError>?
    
    private var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.flow?.minimumInteritemSpacing = 0
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
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
    
}

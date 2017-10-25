//
//  ReminderGedegDataSource.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 24/10/17.
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

import WaterMeData
import UIKit

class ReminderGedegDataSource: ReminderGedeg {

    private weak var collectionView: UICollectionView?

    init?(basicRC: BasicController?, managedCollectionView: UICollectionView?) {
        self.collectionView = managedCollectionView
        super.init(basicRC: basicRC)
    }

    override func allDataReady() {
        super.allDataReady()
        self.collectionView?.reloadData()
    }

    override func updates(in section: ReminderSection, deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.collectionView?.performBatchUpdates({
            self.collectionView?.insertItems(at: insertions.map({ IndexPath(row: $0, section: section.rawValue) }))
            self.collectionView?.deleteItems(at: deletions.map({ IndexPath(row: $0, section: section.rawValue) }))
            self.collectionView?.reloadItems(at: modifications.map({ IndexPath(row: $0, section: section.rawValue) }))
        }, completion: nil)
    }
}

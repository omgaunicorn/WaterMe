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

    override func batchedUpdates(_ updates: [Update]) {
        guard updates.isEmpty == false, let cv = self.collectionView else { return }
        cv.performBatchUpdates({
            let sectionsChanged = Set(updates.map({ $0.section.rawValue }))
            cv.reloadSections(IndexSet(sectionsChanged))
        }, completion: { success in
            guard success == false else { return }
            let message = "CollectionView failed to Reload Sections: This usually happens when data changes really fast"
            log.warning(message)
            cv.reloadData()
        })
    }
}

// old dead code that crashes on last delete
/*
let ins = updates.flatMap() { update in
    return update.insertions.map({ IndexPath(row: $0, section: update.section.rawValue) })
}
let del = updates.flatMap() { update in
    return update.deletions.map({ IndexPath(row: $0, section: update.section.rawValue) })
}
let mod = updates.flatMap() { update in
    return update.modifications.map({ IndexPath(row: $0, section: update.section.rawValue) })
}
cv.insertItems(at: ins)
cv.deleteItems(at: del)
cv.reloadItems(at: mod)
*/

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

protocol CollectionViewReplacer: class {
    func collectionViewReplacementRecommended()
}

class ReminderGedegDataSource: ReminderGedeg {

    private weak var collectionViewReplacer: CollectionViewReplacer?
    private weak var collectionView: UICollectionView?

    init?(basicRC: BasicController?,
          managedCollectionView: UICollectionView?,
          collectionViewReplacer: CollectionViewReplacer?)
    {
        self.collectionViewReplacer = collectionViewReplacer
        self.collectionView = managedCollectionView
        super.init(basicRC: basicRC)

        /*
        // Uncomment to test exception throwing
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            print("___ CAUSING EXCEPTION ___")
            self.batchedUpdates(ins: [], dels: [IndexPath(item: 0, section: 0)], mods: [])
        }
        */
    }

    override func allDataReady() {
        super.allDataReady()
        self.collectionView?.reloadData()
    }

    override func batchedUpdates(ins: [IndexPath], dels: [IndexPath], mods: [IndexPath]) {
        guard let cv = self.collectionView else {
            let error = "CollectionView is NIL. Something really bad happened."
            log.error(error)
            assertionFailure(error)
            return
        }
        let allEmpty = ins.isEmpty && dels.isEmpty && mods.isEmpty
        guard allEmpty == false else {
            // there is nothing to be done, so bail out early
            return
        }
        guard cv.window != nil else {
            // we're not in the view hierarchy
            // no need for animated stuff to happen
            cv.reloadData()
            return
        }
        // sanity checking can only be done when the collectionview
        // is in the window hierarchy. Otherwise its internal state
        // does not update. So it will pass the first sanity check
        // but after that its internal state is stale
        // so it will fail them
        let failureReason = ItemAndSectionSanityCheckFailureReason.check(old: cv, new: self, delta: (ins, dels))
        guard failureReason == nil else {
            let error = NSError(errorFromSanityCheckFailureReason: failureReason!)
            assertionFailure(String(describing: error))
            Analytics.log(error: error)
            log.error(error)
            cv.reloadData()
            return
        }
        TCF.try({
            cv.performBatchUpdates({
                cv.insertItems(at: ins)
                cv.deleteItems(at: dels)
                cv.reloadItems(at: mods)
            }, completion: { success in
                guard success == false else { return }
                let message = "CollectionView failed to Reload Sections: This usually happens when data changes really fast"
                log.warning(message)
                cv.reloadData()
            })
        }, shouldCatch: { exception in
            guard case .internalInconsistencyException = exception.name else {
                return false
            }
            let error = NSError(collectionViewBatchUpdateException: exception)
            Analytics.log(error: error)
            log.error(error)
            return true
        }, finally: { exceptionWasCaught in
            guard exceptionWasCaught == true else { return }
            self.collectionViewReplacer?.collectionViewReplacementRecommended()
        })
    }
}

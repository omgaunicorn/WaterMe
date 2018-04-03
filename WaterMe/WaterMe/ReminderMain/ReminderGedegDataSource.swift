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
        let sanityError = self.sanityCheck(ins: ins, dels: dels, with: cv)
        guard sanityError == nil else {
            assertionFailure(String(describing: sanityError!))
            Analytics.log(error: sanityError!)
            log.error(sanityError!)
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
            log.error(sanityError!)
            return true
        }, finally: { exceptionWasCaught in
            guard exceptionWasCaught == true else { return }
            self.collectionViewReplacer?.collectionViewReplacementRecommended()
        })
    }
}

extension ReminderGedegDataSource {
    // this is an attempt to do the sanity check the collectionview does when doing a batch update
    // before doing the batch up. So that we can bail out and just do reloadData
    // to avoid having an exception thrown
    func sanityCheck(ins: [IndexPath], dels: [IndexPath], with cv: UICollectionView) -> NSError? {
        let insCount = ins.sectionCountDictionary()
        let delsCount = dels.sectionCountDictionary()
        for section in Reminder.Section.all {
            let secRaw = section.rawValue
            let insCount = insCount[secRaw, default: 0]
            let delCount = delsCount[secRaw, default: 0]
            let cvCount = cv.numberOfItems(inSection: secRaw)
            let dataCount = self.numberOfItems(inSection: secRaw)
            if insCount + delCount > 0 {
                let test = cvCount + insCount - delCount == dataCount
                log.debug("Sanity Check: Modified Section: \(section): \(test)")
                if !test {
                    return NSError(collectionViewSanityCheckFailedForModifiedSection: secRaw,
                                                                             cvCount: cvCount,
                                                                           dataCount: dataCount,
                                                                                 ins: insCount,
                                                                                dels: delCount)
                }
            } else {
                let test = cvCount == dataCount
                log.debug("Sanity Check: Unmodified Section: \(section): \(test)")
                if !test {
                    return NSError(collectionViewSanityCheckFailedForUnmodifiedSection: secRaw,
                                                                               cvCount: cvCount,
                                                                             dataCount: dataCount)

                }
            }
        }
        return nil
    }
}

extension Sequence where Iterator.Element == IndexPath {
    func sectionCountDictionary() -> [Int : Int] {
        return self.reduce(into: [Int : Int](), { $0[$1.section, default: 0] += 1 })
    }
}

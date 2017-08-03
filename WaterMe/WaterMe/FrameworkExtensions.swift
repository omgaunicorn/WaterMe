//
//  FrameworkExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
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
import WaterMeData
import FormatterKit
import UIKit

class ContentSizeReloadCollectionViewController: UICollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.contentSizeCategoryDidChange(_:)),
                                               name: .UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    @objc private func contentSizeCategoryDidChange(_ aNotification: Any) {
        // TableViewControllers do this automatically
        // Whenever the text size is changed by the user, just reload the collection view
        // then all the cells get their attributed strings re-set
        self.collectionView?.reloadData()
    }
}

extension UITableView {
    func deselectSelectedRows(animated: Bool) {
        let selectedIndexPaths = self.indexPathsForSelectedRows ?? []
        selectedIndexPaths.forEach() { indexPath in
            self.deselectRow(at: indexPath, animated: animated)
        }
    }
}

extension Sequence {
    func first<T>(of type: T.Type? = nil) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        let indexPaths = self.indexPathsForSelectedItems
        indexPaths?.forEach({ self.deselectItem(at: $0, animated: animated) })
    }
}

extension Receipt {
    var serverPurchasedSubscription: PurchasedSubscription? {
        guard let pID = self.server_productID, let exp = self.server_expirationDate, let pur = self.server_purchaseDate else { return nil }
        return PurchasedSubscription(productID: pID, purchaseDate: pur, expirationDate: exp)
    }
    
    var clientPurchasedSubscription: PurchasedSubscription? {
        guard let pID = self.client_productID, let exp = self.client_expirationDate, let pur = self.client_purchaseDate else { return nil }
        return PurchasedSubscription(productID: pID, purchaseDate: pur, expirationDate: exp)
    }
}

extension Formatter {
    class var newReminderIntervalFormatter: DateComponentsFormatter {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.month, .weekOfMonth, .day]
        f.unitsStyle = .full
        return f
    }
    class var newTimeAgoFormatter: TTTTimeIntervalFormatter {
        let f = TTTTimeIntervalFormatter()
        f.usesApproximateQualifier = true
        f.usesIdiomaticDeicticExpressions = true
        return f
    }
}

extension TTTTimeIntervalFormatter {
    func timeAgoString(for interval: TimeInterval?) -> String {
        guard let interval = interval else { return "Never" }
        let intervalString = self.string(forTimeInterval: interval)
        assert(intervalString != nil, "Time Ago Formatter Returned NIL for Interval: \(interval)")
        return intervalString ?? "–"
    }
}

extension DateComponentsFormatter {
    func string(forDayInterval interval: Int) -> String {
        let time = TimeInterval(interval) * (60 * 60 * 24)
        let string = self.string(from: time)
        assert(string != nil, "Time Interval Formatter Returned NIL for Interval: \(interval)")
        return string ?? "–"
    }
}

extension UIAlertController {
    
    enum Selection {
        case cancel, saveAnyway, error(UserFacingError)
    }
    
    private convenience init(error: UserFacingError, completion: @escaping (Selection) -> Void) {
        self.init(title: error.alertTitle, message: error.alertMessage, preferredStyle: .alert)
        let fix = UIAlertAction(title: "Fix Issue", style: .cancel, handler: { _ in completion(.error(error)) })
        let save = UIAlertAction(title: "Save Anyway", style: .destructive, handler: { _ in completion(.saveAnyway) })
        self.addAction(fix)
        self.addAction(save)
    }
    
    private convenience init(actionSheetWithActions actions: [UIAlertAction], cancelSaveCompletion completion: @escaping (Selection) -> Void) {
        self.init(title: nil, message: "There are some issues you might want to resolve.", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Fix Issues", style: .cancel, handler: { _ in completion(.cancel) })
        let save = UIAlertAction(title: "Save Anyway", style: .destructive, handler: { _ in completion(.saveAnyway) })
        actions.forEach({ self.addAction($0) })
        self.addAction(cancel)
        self.addAction(save)
    }
    
    class func presentAlertVC(for errors: [UserFacingError],
                              over presentingVC: UIViewController,
                              from barButtonItem: UIBarButtonItem?,
                              completionHandler completion: @escaping (Selection) -> Void)
    {
        let errorActions = errors.map() { error -> UIAlertAction in
            let action = UIAlertAction(title: error.alertTitle, style: .default) { _ in
                if error.alertMessage == nil {
                    // if the alertMessage is NIL, just call the completion handler
                    completion(.error(error))
                } else {
                    // otherwise, make a new alert that gives the user more detailed information
                    let errorAlert = UIAlertController(error: error, completion: completion)
                    presentingVC.present(errorAlert, animated: true, completion: nil)
                }
            }
            return action
        }
        assert(barButtonItem != nil, "Expected to be passed a UIBarButtonItem")
        let actionSheet = UIAlertController(actionSheetWithActions: errorActions, cancelSaveCompletion: completion)
        actionSheet.popoverPresentationController?.barButtonItem = barButtonItem
        presentingVC.present(actionSheet, animated: true, completion: nil)
    }
}

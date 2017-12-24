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
import UserNotifications

extension UNUserNotificationCenter {
    func authorized(completion: @escaping (Bool) -> Void) {
        self.getNotificationSettings() { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus.boolValue)
            }
        }
    }
}

extension MutableCollection {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}


extension UNAuthorizationStatus {
    var boolValue: Bool {
        switch self {
        case .authorized:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}

class StandardCollectionViewController: UICollectionViewController {

    var flow: UICollectionViewFlowLayout? {
        return self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    var itemHeight: CGFloat {
        return 100
    }

    var columnCount: Int {
        return 2
    }

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

    /// Updates flow layout based on `columnCount` and `itemHeight` properties
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateFlowItemSize()
    }

    private func updateFlowItemSize() {
        let columnCount = CGFloat(self.columnCount)
        let height = self.itemHeight
        // calculate width of collectionView with insets accounted for
        let rawWidth = self.collectionView?.bounds.width ?? 0
        let insets = self.collectionView?.adjustedContentInset ?? .zero
        let width = rawWidth - insets.left - insets.right
        // calculate column width based on usable width of collectionview
        let division = width / columnCount
        self.flow?.itemSize = CGSize(width: floor(division), height: height)
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
        guard let interval = interval else { return ReminderMainViewController.LocalizedString.timeAgoLabelNever }
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

// Alerts for presenting realm errors
extension UIAlertController {
    
    enum ErrorSelection<T: UserFacingError> {
        case cancel, error(T)
    }
    
    convenience init<T>(error: T, completion: ((ErrorSelection<T>) -> Void)?) {
        self.init(title: error.title, message: error.details, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel, handler: { _ in completion?(.cancel) })
        self.addAction(cancelAction)
        if let actionTitle = error.actionTitle {
            let errorAction = UIAlertAction(title: actionTitle, style: .default, handler: { _ in completion?(.error(error)) })
            self.addAction(errorAction)
        }
    }
}

// Alerts for presenting User Input Validation Errors
extension UIAlertController {
    
    enum SaveAnywayErrorSelection<T: UserFacingError> {
        case cancel, saveAnyway, error(T)
    }
    
    private convenience init<T>(saveAnywayError error: T, completion: @escaping (SaveAnywayErrorSelection<T>) -> Void) {
        self.init(title: error.title, message: error.details, preferredStyle: .alert)
        if let actionTitle = error.actionTitle {
            let fix = UIAlertAction(title: actionTitle, style: .default, handler: { _ in completion(.error(error)) })
            self.addAction(fix)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleCancel, style: .cancel, handler: { _ in completion(.cancel) })
        let save = UIAlertAction(title: LocalizedString.buttonTitleSaveAnyway, style: .destructive, handler: { _ in completion(.saveAnyway) })
        self.addAction(cancel)
        self.addAction(save)
    }
    
    private convenience init<T>(actionSheetWithActions actions: [UIAlertAction], cancelSaveCompletion completion: @escaping (SaveAnywayErrorSelection<T>) -> Void) {
        self.init(title: nil, message: LocalizedString.titleUnsolvedIssues, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleCancel, style: .cancel, handler: { _ in completion(.cancel) })
        let save = UIAlertAction(title: LocalizedString.buttonTitleSaveAnyway, style: .destructive, handler: { _ in completion(.saveAnyway) })
        actions.forEach({ self.addAction($0) })
        self.addAction(cancel)
        self.addAction(save)
    }
    
    class func presentAlertVC<T>(for errors: [T],
                                 over presentingVC: UIViewController,
                                 from barButtonItem: UIBarButtonItem?,
                                 completionHandler completion: @escaping (SaveAnywayErrorSelection<T>) -> Void)
    {
        let errorActions = errors.map() { error -> UIAlertAction in
            let action = UIAlertAction(title: error.title, style: .default) { _ in
                if error.details == nil {
                    // if the alertMessage is NIL, just call the completion handler
                    completion(.error(error))
                } else {
                    // otherwise, make a new alert that gives the user more detailed information
                    let errorAlert = UIAlertController(saveAnywayError: error, completion: completion)
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

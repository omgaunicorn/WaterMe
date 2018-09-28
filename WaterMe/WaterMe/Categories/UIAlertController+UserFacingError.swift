//
//  UIAlertController+UserFacingError.swift
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

import WaterMeData
import UIKit

// Alerts for presenting realm errors
extension UIAlertController {

    enum ErrorSelection<T: UserFacingError> {
        case cancel, error(T)
    }

    convenience init<T>(error: T, completion: ((ErrorSelection<T>) -> Void)?) {
        Analytics.log(viewOperation: .errorAlertRealm)
        self.init(title: error.title, message: error.details, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel, handler: { _ in completion?(.cancel) })
        self.addAction(cancelAction)
        switch error.recoveryActions {
        case .none:
            break
        case .openWaterMeSettings:
            let actionTitle = RealmError.LocalizedString.buttonTitleManageStorage
            let errorAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                UIApplication.shared.openAppSettings(completion: nil)
                completion?(.error(error))
            }
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
        switch error.recoveryActions {
        case .none:
            break
        case .openWaterMeSettings:
            let actionTitle = RealmError.LocalizedString.buttonTitleManageStorage
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

extension UIAlertController {
    class func sourceRect(from view: UIView) -> CGRect {
        let origin = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        return CGRect(origin: origin, size: .zero)
    }
}

extension UIAlertController {
    convenience init(localizedDeleteConfirmationAlertPresentedFrom sender: Either<UIBarButtonItem, UIView>?,
                     userConfirmationHandler confirmed: ((Bool) -> Void)?)
    {
        let style: UIAlertControllerStyle = sender != nil ? .actionSheet : .alert
        self.init(title: nil, message: LocalizedString.deleteAlertMessage, preferredStyle: style)
        let delete = UIAlertAction(title: LocalizedString.buttonTitleDelete, style: .destructive) { _ in
            confirmed?(true)
        }
        let dont = UIAlertAction(title: LocalizedString.buttonTitleDontDelete, style: .cancel) { _ in
            confirmed?(false)
        }
        self.addAction(delete)
        self.addAction(dont)
        guard let sender = sender else { return }
        switch sender {
        case .left(let bbi):
            self.popoverPresentationController?.barButtonItem = bbi
        case .right(let view):
            self.popoverPresentationController?.sourceView = view
            self.popoverPresentationController?.sourceRect = type(of: self).sourceRect(from: view)
            self.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        }
    }
}

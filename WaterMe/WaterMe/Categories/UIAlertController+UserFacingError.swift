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

extension UIAlertController {
    
    typealias UserSelection = (RecoveryAction) -> Void
    
    class func presentAlertVC(for error: UserFacingError,
                              over presentingVC: UIViewController,
                              from barButtonItem: UIBarButtonItem? = nil,
                              completionHandler completion: UserSelection? = nil)
    {
        let recoveryActions = error.recoveryActions.map()
        { recoveryOption -> UIAlertAction in
            let action = UIAlertAction(title: recoveryOption.title,
                                       style: recoveryOption.actionStyle)
            { _ in
                completion?(recoveryOption)
            }
            return action
        }
        let actionSheet: UIAlertController
        if let bbi = barButtonItem {
            actionSheet = .init(title: error.title,
                                message: error.message,
                                preferredStyle: .actionSheet)
            actionSheet.popoverPresentationController?.barButtonItem = bbi
        } else {
            actionSheet = .init(title: error.title,
                                message: error.message,
                                preferredStyle: .alert)
        }
        recoveryActions.forEach(actionSheet.addAction)
        presentingVC.present(actionSheet, animated: true, completion: nil)
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

extension UIAlertController {
    convenience init(localizedSiriShortcutsUnavailableAlertWithCompletionHandler completion: (() -> Void)?) {
        self.init(title: UserActivityConfigurator.LocalizedString.siriShortcutsUnavailableTitle,
                  message: UserActivityConfigurator.LocalizedString.siriShortcutsUnavailableMessage,
                  preferredStyle: .alert)
        let dismiss = UIAlertAction(title: LocalizedString.buttonTitleDismiss,
                                    style: .cancel)
        { _ in
            completion?()
        }
        self.addAction(dismiss)
    }
}

extension UIAlertController {
    class func sourceRect(from view: UIView) -> CGRect {
        let origin = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        return CGRect(origin: origin, size: .zero)
    }
}

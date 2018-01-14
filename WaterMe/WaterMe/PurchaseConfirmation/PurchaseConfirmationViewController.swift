//
//  PurchaseConfirmationViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 13/1/18.
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
import UIKit

class PurchaseConfirmationViewController: UIViewController {

    class func newVC(for inFlight: InFlightTransaction, completion: ((UIViewController?) -> Void)?) -> UIViewController? {
        let alert: UIAlertController
        switch inFlight.state {
        case .cancelled:
            return nil
        case .success:
            alert = UIAlertController(title: "Thanks!!!", message: nil, preferredStyle: .alert)
        case .errorNetwork:
            alert = UIAlertController(title: "Purchase Error", message: "A network error ocurred. Check your data connection and try and make the purchase again later.", preferredStyle: .alert)
        case .errorNotAllowed:
            alert = UIAlertController(title: "Purchase Error", message: "It looks like you're not allowed to buy in-app purchases. Thanks for trying though.", preferredStyle: .alert)
        case .errorUnknown:
            alert = UIAlertController(title: "Purchase Error", message: "An unknown error ocurred. Try and make the purchase again later.", preferredStyle: .alert)
        }
        let confirm = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            AppDelegate.shared.purchaseController?.finish(inFlight: inFlight)
            completion?(nil)
        }
        alert.addAction(confirm)
        return alert
    }
}

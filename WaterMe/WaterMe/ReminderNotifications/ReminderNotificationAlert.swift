//
//  ReminderNotificationAlert.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/1/18.
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

import UserNotifications
import UIKit

extension UIAlertController {
    class func newRequestPermissionAlert(selection: (() -> Void)?) -> UIAlertController? {
        guard UserDefaults.standard.userNeedsToBeAskedAboutNotifications == true else { return nil }
        let title = "Push Notifications"
        let message = "Do you want WaterMe to send notifications when your plants need attention? WaterMe sends no more than 1 per day."
        let vc = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let yes = UIAlertAction(title: "Send Notifications", style: .default) { _ in
            UserDefaults.standard.userNeedsToBeAskedAboutNotifications = false
            UNUserNotificationCenter.current().requestAuthorizationIfNeeded(completion: nil)
            selection?()
        }
        let no = UIAlertAction(title: "Don't Send Notifications", style: .default) { _ in
            UserDefaults.standard.userNeedsToBeAskedAboutNotifications = false
            selection?()
        }
        let cancel = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            selection?()
        }
        vc.addAction(yes)
        vc.addAction(no)
        vc.addAction(cancel)
        return vc
    }
}

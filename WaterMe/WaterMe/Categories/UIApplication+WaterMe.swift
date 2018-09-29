//
//  UIApplication+WaterMe.swift
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

import WaterMeStore
import UIKit

extension UIApplication {

    func openAppSettings(completion: ((Bool) -> Void)?) {
        Analytics.log(viewOperation: .openSettings)
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        self.open(url, options: [:], completionHandler: completion)
    }

    func openWriteReviewPage(completion: ((Bool) -> Void)?) {
        guard let url = PrivateKeys.kReviewAppURL else {
            completion?(false)
            return
        }
        Analytics.log(viewOperation: .openAppStoreReview)
        self.open(url, options: [:], completionHandler: completion)
    }

    func openAppStorePage(completion: ((Bool) -> Void)?) {
        guard let url = PrivateKeys.kAppStoreURL else {
            completion?(false)
            return
        }
        Analytics.log(viewOperation: .openAppStore)
        self.open(url, options: [:], completionHandler: completion)
    }
}

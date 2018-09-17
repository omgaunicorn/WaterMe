//
//  AppVersionCheckingAlert.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/16/18.
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

import UIKit
import WaterMeStore

extension UIAlertController {
    class func newAppVersionCheckAlert(_ completion: @escaping (UIAlertController?) -> Void) {
        let bundle = Bundle(for: AppDelegate.self)
        guard let currentVersion = AppVersion.fetchFromBundle() else {
            completion(nil)
            return
        }
        AppVersion.fetchFromAppStore() { appStoreVersion in
            guard let appStoreVersion = appStoreVersion else {
                completion(nil)
                return
            }
            if bundle.isTestFlightInstall {
                guard appStoreVersion >= currentVersion else {
                    completion(nil)
                    return
                }
                let alert = UIAlertController(title: "Testflight Update", message: "Something!", preferredStyle: .alert)
                let update = UIAlertAction(title: "Open App Store", style: .default) { action in

                }
                let cancel = UIAlertAction(title: "Caaaannnncel", style: .cancel, handler: nil)
                alert.addAction(update)
                alert.addAction(cancel)
                completion(alert)
            } else {
                guard appStoreVersion > currentVersion else {
                    completion(nil)
                    return
                }
                let alert = UIAlertController(title: "Update", message: "Something!", preferredStyle: .alert)
                let update = UIAlertAction(title: "Open App Store", style: .default) { action in

                }
                let cancel = UIAlertAction(title: "Caaaannnncel", style: .cancel, handler: nil)
                alert.addAction(update)
                alert.addAction(cancel)
                completion(alert)
            }
        }
    }
}

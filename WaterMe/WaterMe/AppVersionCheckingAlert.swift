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
                let alert = UIAlertController(newUpdateAvailableAlertForTestFlight: true)
                completion(alert)
            } else {
                guard appStoreVersion > currentVersion else {
                    completion(nil)
                    return
                }
                let alert = UIAlertController(newUpdateAvailableAlertForTestFlight: false)
                completion(alert)
            }
        }
    }

    private convenience init(newUpdateAvailableAlertForTestFlight forTestFlight: Bool) {
        switch forTestFlight {
        case true:
            self.init(title: "Update Available", message: "Thank you for beta testing WaterMe! A newer version of this application is now available on the App Store.", preferredStyle: .alert)
        case false:
            self.init(title: "Update Available", message: "Thank you for using WaterMe! A newer version of this application is now available on the App Store.", preferredStyle: .alert)
        }
        let appStore = UIAlertAction(title: "Open App Store", style: .default, handler: nil)
        let dontAsk = UIAlertAction(title: LocalizedString.buttonTitleDontAskAgain, style: .destructive, handler: nil)
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel, handler: nil)
        self.addAction(appStore)
        self.addAction(dontAsk)
        self.addAction(cancel)
    }
}

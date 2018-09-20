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

    enum UpdateAction {
        case update, dontAsk, cancel
    }

    class func newAppVersionCheckAlert(_ completion: @escaping (UIViewController?) -> Void,
                                       _ actionHandler: @escaping (UpdateAction) -> Void)
    {
        guard UserDefaults.standard.checkForUpdatesOnLaunch else {
            completion(nil)
            return
        }
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
                let alert = UIAlertController(newUpdateAvailableAlertForTestFlight: true,
                                              actionHandler: actionHandler)
                completion(alert)
            } else {
                guard appStoreVersion > currentVersion else {
                    completion(nil)
                    return
                }
                let alert = UIAlertController(newUpdateAvailableAlertForTestFlight: false,
                                              actionHandler: actionHandler)
                completion(alert)
            }
        }
    }

    private convenience init(newUpdateAvailableAlertForTestFlight forTestFlight: Bool,
                             actionHandler: @escaping (UpdateAction) -> Void)
    {
        switch forTestFlight {
        case true:
            self.init(title: LocalizedString.updateAvailableAlertTitle,
                      message: LocalizedString.updateAvailableTestFlightAlertMessage,
                      preferredStyle: .alert)
        case false:
            self.init(title: LocalizedString.updateAvailableAlertTitle,
                      message: LocalizedString.updateAvailableAlertMessage,
                      preferredStyle: .alert)
        }
        let appStore = UIAlertAction(title: LocalizedString.updateAvailableButtonTitleOpenAppStore,
                                     style: .default,
                                     handler: { _ in actionHandler(.update) })
        let dontAsk = UIAlertAction(title: LocalizedString.buttonTitleDontAskAgain,
                                    style: .destructive,
                                    handler: { _ in actionHandler(.dontAsk) })
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss,
                                   style: .cancel,
                                   handler: { _ in actionHandler(.cancel) })
        self.addAction(appStore)
        self.addAction(dontAsk)
        self.addAction(cancel)
    }
}

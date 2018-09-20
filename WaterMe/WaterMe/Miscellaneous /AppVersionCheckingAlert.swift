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
        case update, cancel
    }

    class func newAppVersionCheckAlert(_ completion: @escaping (UIViewController?) -> Void,
                                       _ actionHandler: @escaping (UpdateAction) -> Void)
    {
        guard UserDefaults.standard.checkForUpdatesOnLaunch else {
            completion(nil)
            return
        }
        let bundle = Bundle(for: AppDelegate.self)
        guard let bundleVersion = AppVersion.fetchFromBundle() else {
            completion(nil)
            return
        }
        AppVersion.fetchFromAppStore() { appStoreVersion in
            guard let appStoreVersion = appStoreVersion else {
                completion(nil)
                return
            }
            let shownDates = UserDefaults.standard.updateDisplayDates(forAppStoreVersion: appStoreVersion)
            switch shownDates.count {
            case 1:
                guard
                    let originallyShownDate = shownDates.first,
                    Calendar.current.enoughTimeHasElapsedSinceOriginallyShownDate(originallyShownDate)
                else {
                    completion(nil)
                    return
                }
                fallthrough
            case 0:
                let preActionHandler = {
                    UserDefaults.standard.markUpdateDisplayed(forAppStoreVersion: appStoreVersion)
                }
                let alert = self.updateAvailableAlertByComparing(appStoreVersion: appStoreVersion,
                                                                 bundleVersion: bundleVersion,
                                                                 isTestFlightInstall: bundle.isTestFlightInstall,
                                                                 preActionHandler: preActionHandler,
                                                                 actionHandler: actionHandler)
                completion(alert)
                return
            default:
                completion(nil)
                return
            }
        }
    }

    private class func updateAvailableAlertByComparing(appStoreVersion: AppVersion,
                                                       bundleVersion: AppVersion,
                                                       isTestFlightInstall: Bool,
                                                       preActionHandler: @escaping () -> Void,
                                                       actionHandler: @escaping (UpdateAction) -> Void) -> UIAlertController?
    {
        if isTestFlightInstall {
            guard appStoreVersion >= bundleVersion else { return nil }
            return UIAlertController(newUpdateAvailableAlertForTestFlight: true,
                                     preActionHandler: preActionHandler,
                                     actionHandler: actionHandler)
        } else {
            guard appStoreVersion > bundleVersion else { return nil }
            return UIAlertController(newUpdateAvailableAlertForTestFlight: false,
                                     preActionHandler: preActionHandler,
                                     actionHandler: actionHandler)
        }
    }

    private convenience init(newUpdateAvailableAlertForTestFlight forTestFlight: Bool,
                             preActionHandler: @escaping () -> Void,
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
        let appStore = UIAlertAction(title: LocalizedString.updateAvailableButtonTitleOpenAppStore, style: .default)
        { _ in
            preActionHandler()
            actionHandler(.update)
        }
        let cancel = UIAlertAction(title: LocalizedString.buttonTitleDismiss, style: .cancel)
        { _ in
            preActionHandler()
            actionHandler(.cancel)
        }
        self.addAction(appStore)
        self.addAction(cancel)
    }
}

fileprivate extension UserDefaults {

    fileprivate static let kAppVersionDisplayDatePrefix = "kAppVersionDisplayDatePrefixKey"

    private static func key(for version: AppVersion) -> String {
        return kAppVersionDisplayDatePrefix + ":" + version.versionString
    }

    fileprivate func updateDisplayDates(forAppStoreVersion version: AppVersion) -> [Date] {
        let key = type(of: self).key(for: version)
        let dates = self.object(forKey: key) as? [Date]
        return dates ?? []
    }

    fileprivate func markUpdateDisplayed(forAppStoreVersion version: AppVersion) {
        let existingDates = self.updateDisplayDates(forAppStoreVersion: version)
        let key = type(of: self).key(for: version)
        self.set(existingDates + [Date()], forKey: key)
    }
}

fileprivate extension Calendar {
    func enoughTimeHasElapsedSinceOriginallyShownDate(_ originallyShownDate: Date) -> Bool {
        let now = Date()
        guard
            let oneWeekAfterShownDate = self.date(byAdding: .weekOfYear,
                                                    value: 1,
                                                    to: originallyShownDate),
            now >= oneWeekAfterShownDate
        else { return false }
        return true
    }
}

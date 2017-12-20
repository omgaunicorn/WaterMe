//
//  AppDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
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

import WaterMeData
import XCGLogger
import UIKit
import UserNotifications
import UserNotificationsUI

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // swiftlint:disable:next force_cast
    class var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    // swiftlint:disable:next weak_delegate
    private let notificationUIDelegate = ReminderNotificationUIDelegate()
    private var notifictionController: ReminderUserNotificationController?

    var window: UIWindow?

    override init() {
        super.init()
        
        // configure logging
        // TODO: Change this to no longer be debug when ready for release
        log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: true, fileLevel: .debug)
        log.formatters = [LogSpreader()]
        
        // as early as possible, configure standard defaults
        UserDefaults.standard.configure()
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self.notificationUIDelegate
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let freeRC = BasicController(kind: .local)
        let vc = ReminderMainViewController.newVC(basicController: freeRC, proController: nil)

        self.notifictionController = ReminderUserNotificationController(basicController: freeRC)

        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        self.window!.backgroundColor = .white
        self.window!.rootViewController = vc
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        let _savedBuild = coder.decodeObject(forKey: UIApplicationStateRestorationBundleVersionKey) as? String
        let _currentBuild = Bundle(for: type(of: self)).infoDictionary?[kCFBundleVersionKey as String] as? String
        guard let savedBuild = _savedBuild, let currentBuild = _currentBuild, currentBuild == savedBuild else { return false }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorizationIfNeeded() { authorized in
            log.debug("Notifications Authorized: \(authorized)")
        }
    }
}

extension UNUserNotificationCenter {
    func requestAuthorizationIfNeeded(completion: ((Bool) -> Void)?) {
        self.getNotificationSettings() { preSettings in
            switch preSettings.authorizationStatus {
            case .authorized, .denied:
                DispatchQueue.main.async {
                    completion?(preSettings.authorizationStatus.boolValue)
                }
            case .notDetermined:
                self.requestAuthorization(options: [.alert, .badge, .sound]) { _, error in
                    if let error = error {
                        log.error("Error requesting notification authorization: \(error)")
                    }
                    self.getNotificationSettings() { postSettings in
                        DispatchQueue.main.async {
                            completion?(postSettings.authorizationStatus.boolValue)
                        }
                    }
                }
            }
        }
    }
}

class ReminderNotificationUIDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
}

class LogSpreader: NSObject, LogFormatterProtocol {

    func format(logDetails: inout LogDetails, message: inout String) -> String {
        // send the log to other services here
        switch logDetails.level {
        case .none:
            break
        case .verbose:
            break
        case .debug:
            break
        case .info:
            break
        case .warning:
            break
        case .error:
            break
        case .severe:
            break
        }
        return ""
    }

}

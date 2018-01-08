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
import UserNotifications
import UserNotificationsUI
import AVFoundation
import UIKit

let log = XCGLogger.default

extension UIApplication {
    func openSettings(completion: ((Bool) -> Void)?) {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        self.open(url, options: [:], completionHandler: completion)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // swiftlint:disable:next force_cast
    class var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    // swiftlint:disable:next weak_delegate
    private let notificationUIDelegate = ReminderNotificationUIDelegate()
    private var notifictionController: ReminderUserNotificationController?

    var coreDataMigrator = CoreDataMigrator()

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
        UIApplication.style_configure()
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Configure audio so the water video does not pause the users music
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

        let result = BasicController.new(of: .local)
        let vc = ReminderMainViewController.newVC(basicRCResult: result, proController: nil)
        self.notifictionController = ReminderUserNotificationController(basicController: result.value)

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

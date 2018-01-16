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

import WaterMeStore
import WaterMeData
import XCGLogger
import Fabric
import Crashlytics
import UserNotifications
import AVFoundation
import StoreKit
import UIKit

let log = XCGLogger.default

extension UIApplication {
    func openSettings(completion: ((Bool) -> Void)?) {
        Analytics.log(viewOperation: .openSettings)
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        self.open(url, options: [:], completionHandler: completion)
    }
    func openWriteReviewPage(completion: ((Bool) -> Void)?) {
        Analytics.log(viewOperation: .openAppStore)
        self.open(PrivateKeys.kReviewAppURL, options: [:], completionHandler: completion)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // swiftlint:disable:next force_cast
    class var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    // swiftlint:disable:next weak_delegate
    private let notificationUIDelegate = ReminderNotificationUIDelegate()
    private(set) var notifictionController: ReminderUserNotificationController?

    let purchaseController = PurchaseController()
    var coreDataMigrator = CoreDataMigrator()
    var window: UIWindow?
    var userDefaultObserverTokens: [NSKeyValueObservation] = []

    override init() {
        super.init()
        
        // configure logging
        log.setup(level: .warning, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .warning)
        
        // as early as possible, configure standard defaults
        UserDefaults.standard.configure()

        // make re-usable closures for notifications I'll register for later
        let appearanceChanges = {
            // need to rip the view hierarchy out of the window and put it back in
            // in order for the new UIAppearance to take effect
            UIApplication.style_configure()
            let prevVC = self.window?.rootViewController
            self.window?.rootViewController = nil
            self.window?.rootViewController = prevVC
        }
        let notificationChanges = {
            self.notifictionController?.notificationPermissionsMayHaveChanged()
        }
        // register for notifications about the increase contrast setting
        _ = NotificationCenter.default.addObserver(forName: .UIAccessibilityDarkerSystemColorsStatusDidChange, object: nil, queue: nil) { _ in
            appearanceChanges()
        }
        // register for notifications if user defaults change while the app is running
        let token1 = UserDefaults.standard.observe(\.INCREASE_CONTRAST) { _, _ in
            appearanceChanges()
        }
        let token2 = UserDefaults.standard.observe(\.REMINDER_HOUR) { _, _ in
            notificationChanges()
        }
        let token3 = UserDefaults.standard.observe(\.NUMBER_OF_REMINDER_DAYS) { _, _ in
            notificationChanges()
        }
        self.userDefaultObserverTokens += [token1, token2, token3]
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // these two closures are for checking if we should ask for a review
        // When a new build is detected, we set a date
        // Two weeks after that date, the user is eligible to be asked for a review
        // Next time they water plants, they will be asked (assuming the system cooperates)
        _ = {
            // check the build and see if its new
            let ud = UserDefaults.standard
            let oldBuild = ud.lastBuildNumber
            let currentBuild = self.buildNumberString
            if oldBuild != currentBuild {
                ud.lastBuildNumber = currentBuild
                ud.requestReviewDate = Date()
            }
        }()
        let checkForReview = {
            let now = Date()
            let ud = UserDefaults.standard
            guard
                let reviewDate = ud.requestReviewDate,
                let forwardDate = Calendar.current.date(byAdding: .weekOfMonth, value: 2, to: reviewDate),
                now >= forwardDate
            else { return }
            log.info("Requested App Review with SKStoreReviewController")
            SKStoreReviewController.requestReview()
            ud.requestReviewDate = nil // nil this out so they won't be asked again until next update
        }

        // Basic Controller error handling closure
        // There is no easy way for my Dynamic Frameworks to be able to use Crashlytics
        // So in the places where they can throw errors, I introduced a static var so we can see them here
        BasicController.errorThrown = { error in
            Crashlytics.sharedInstance().recordError(error)
        }

        // configure Crashlytics
        Crashlytics.start(withAPIKey: WaterMeData.PrivateKeys.kFrabicAPIKey)

        // configure my notification delegate
        UNUserNotificationCenter.current().delegate = self.notificationUIDelegate

        // style the app with UIAppearance methods
        UIApplication.style_configure()

        // Configure audio so the water video does not pause the users music
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)

        let result = BasicController.new(of: .local)
        let vc = ReminderMainViewController.newVC(basicRCResult: result, proController: nil)
        self.notifictionController = ReminderUserNotificationController(basicController: result.value)

        result.value?.userDidPerformReminder = checkForReview

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

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
import UserNotifications
import AVFoundation
import StoreKit
import UIKit

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // swiftlint:disable:next force_cast
    class var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    // swiftlint:disable:next weak_delegate
    private let notificationUIDelegate = ReminderNotificationUIDelegate()
    private(set) var reminderObserver: GlobalReminderObserver?
    private lazy var basicControllerResult = BasicController.new(of: .local)

    let purchaseController = PurchaseController()
    var coreDataMigrator: CoreDataMigratable? = CoreDataMigrator()
    var window: UIWindow?
    var userDefaultObserverTokens: [NSKeyValueObservation] = []

    private var rootVC: ReminderMainViewController? {
        let navVC = self.window?.rootViewController as? UINavigationController
        let vc = navVC?.viewControllers.first as? ReminderMainViewController
        assert(vc != nil)
        return vc
    }

    override init() {
        super.init()

        // configure logging
        #if DEBUG
        log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .debug)
        #else
        log.setup(level: .warning, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .warning)
        #endif

        // print the simulator directory if possible
        if let docs = UIDevice.debug_documentsDirectory() {
            log.debug(docs)
        }

        // configure main thread checking
        DispatchQueue.configureMainQueue()
        
        // as early as possible, configure standard defaults
        let ud = UserDefaults.standard
        ud.configure()

        // make re-usable closures for notifications I'll register for later
        let appearanceChanges = { [weak self] in
            // if the window is not configured yet, bail
            guard
                let self = self,
                let window = self.window
            else { return }

            // need to rip the view hierarchy out of the window and put it back in
            // in order for the new UIAppearance to take effect
            UIApplication.style_configure()

            // force window to update everything by
            // get the old vc in iOS 13
            var newVC: UIViewController!
            if #available(iOS 13.0, *) {
                newVC = window.rootViewController
            }
            // create a new VC in older versions
            // for some reason this is needed
            if newVC == nil {
                let result = self.basicControllerResult
                newVC = ReminderMainViewController.newVC(basic: result)
            }
            // clear the vc from the window
            window.rootViewController = nil
            // configuring the window
            window.style_configure()
            // replace with newVC
            window.rootViewController = newVC
        }
        let notificationChanges = {
            self.reminderObserver?.notificationPermissionsMayHaveChanged()
        }
        // register for notifications about the increase contrast setting
        _ = NotificationCenter.default.addObserver(forName: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
                                                   object: nil,
                                                   queue: nil)
        { _ in
            appearanceChanges()
        }
        // register for notifications if user defaults change while the app is running
        let token1 = ud.observe(\.INCREASE_CONTRAST) { _, _ in
            appearanceChanges()
        }
        let token2 = ud.observe(\.DARK_MODE) { _, _ in
            appearanceChanges()
        }
        let token3 = ud.observe(\.REMINDER_HOUR) { _, _ in
            notificationChanges()
        }
        let token4 = ud.observe(\.NUMBER_OF_REMINDER_DAYS) { _, _ in
            notificationChanges()
        }
        let token5 = ud.observe(\.FIRST_RUN) { _, _ in
            notificationChanges()
        }
        self.userDefaultObserverTokens += [token1, token2, token3, token4, token5]
    }
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {

        // see if there is a new build
        _ = {
            // check the build and see if its new
            let ud = UserDefaults.standard
            let oldBuild = ud.lastBuildNumber
            let currentBuild = Bundle.main.buildNumber
            if oldBuild != currentBuild {
                ud.lastBuildNumber = currentBuild
                ud.requestReviewDate = Date()
            }
        }()

        // Basic Controller error handling closure
        // There is no easy way for my Dynamic Frameworks to be able to use Crashlytics
        // So in the places where they can throw errors, I introduced a static var so we can see them here
        BasicController.errorThrown = { error in
            log.error(error)
            Analytics.log(error: error)
        }

        // configure my notification delegate
        UNUserNotificationCenter.current().delegate = self.notificationUIDelegate

        // style the app with UIAppearance methods
        UIApplication.style_configure()

        // Configure audio so the water video does not pause the users music
        try? AVAudioSession.sharedInstance().setCategory(.ambient)

        let result = self.basicControllerResult
        let vc = ReminderMainViewController.newVC(basic: result)
        if case .success(let basicRC) = result {
            self.reminderObserver = GlobalReminderObserver(basicController: basicRC)
        }

        // When a new build is detected, we set a date
        // Two weeks after that date, the user is eligible to be asked for a review
        // Next time they water plants, they will be asked (assuming the system cooperates)
        result.value?.userDidPerformReminder = {
            let now = Date()
            let ud = UserDefaults.standard
            guard
                let reviewDate = ud.requestReviewDate,
                let forwardDate = Calendar.current.date(byAdding: .weekOfMonth,
                                                        value: 2,
                                                        to: reviewDate),
                now >= forwardDate
            else { return }
            log.info("Requested App Review with SKStoreReviewController")
            Analytics.log(event: Analytics.Event.reviewRequested)
            SKStoreReviewController.requestReview()
            ud.requestReviewDate = nil // nil this out so they won't be asked again until next update
        }

        // configure window
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        window.style_configure()
        window.rootViewController = vc

        // show window
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }

    func application(_ application: UIApplication,
                     willContinueUserActivityWithType userActivityType: String) -> Bool
    {
        guard RawUserActivity(rawValue: userActivityType) != nil else {
            return false
        }
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping NSUserActivityContinuedHandler) -> Bool
    {
        let result: UserActivityResult
            = userActivity.restoredUserActivityResult
                .bimap(success: { UserActivityToContinue(activity: $0, completion: restorationHandler) },
                       failure: { UserActivityToFail(error: $0, completion: restorationHandler) })
        self.rootVC?.userActivityResultToContinue += [result]
        let isReady = self.rootVC?.isReady ?? []
        guard isReady.completely else { return true }
        self.rootVC?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        return true
    }

    func application(_ application: UIApplication,
                     didFailToContinueUserActivityWithType userActivityType: String,
                     error: Error)
    {
        let error = error as NSError
        guard error.code != NSUserCancelledError else {
            return
        }
        let result: UserActivityResult
            = .failure(UserActivityToFail(error: .continuationFailed, completion: nil))
        self.rootVC?.userActivityResultToContinue += [result]
        let isReady = self.rootVC?.isReady ?? []
        guard isReady.completely else { return }
        self.rootVC?.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
    }

    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication,
                     shouldRestoreSecureApplicationState coder: NSCoder) -> Bool
    {
        let _savedBuild = coder.decodeObject(forKey: UIApplication.stateRestorationBundleVersionKey) as? String
        let _currentBuild = Bundle(for: type(of: self)).infoDictionary?[kCFBundleVersionKey as String] as? String
        guard
            let savedBuild = _savedBuild,
            let currentBuild = _currentBuild,
            currentBuild == savedBuild
        else { return false }
        return true
    }

    @available(*, deprecated, message: "This is deprecated. Only implemented for old iOS support.")
    func application(_ application: UIApplication,
                     shouldSaveApplicationState coder: NSCoder) -> Bool
    {
        return self.application(application, shouldSaveSecureApplicationState: coder)
    }
    
    @available(*, deprecated, message: "This is deprecated. Only implemented for old iOS support.")
    func application(_ application: UIApplication,
                     shouldRestoreApplicationState coder: NSCoder) -> Bool
    {
        return self.application(application, shouldRestoreSecureApplicationState: coder)
    }
}

extension UIDevice {
    // x86 checking doesn't work on mac catalyst
    // this error will force me to improve the logic later
    @available(macCatalyst, unavailable)
    fileprivate class func debug_documentsDirectory() -> String? {
        #if arch(i386) || arch(x86_64)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath
        #endif
        return nil
    }
}

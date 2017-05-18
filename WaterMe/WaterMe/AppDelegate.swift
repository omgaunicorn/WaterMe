//
//  AppDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import XCGLogger
import UIKit

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let receiptMonitor = ReceiptMonitor()
        
    override init() {
        super.init()
        
        // configure logging
        log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: true, fileLevel: .debug)
        
        // as early as possible, configure standard defaults
        UserDefaults.standard.configure()
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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

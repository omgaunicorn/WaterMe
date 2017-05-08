//
//  AppDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init() {
        super.init()
        
        // as early as possible, configure standard defaults
        UserDefaults.standard.configure()
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let vc = UIViewController()
        
        window.rootViewController = vc
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
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


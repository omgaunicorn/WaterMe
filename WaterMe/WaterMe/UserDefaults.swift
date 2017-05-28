//
//  UserDefaults.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import Foundation

extension UserDefaults {
    
    enum Constants {
        static let kFirstRun = "FIRST_RUN"
        static let kReminderHour = "REMINDER_HOUR"
        static let kNumberOfReminderDays = "NUMBER_OF_REMINDER_DAYS"
    }
    
    var isFirstRun: Bool {
        get {
            guard let number = self.object(forKey: Constants.kFirstRun) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.boolValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kFirstRun)
        }
    }
    
    var reminderHour: Int {
        get {
            guard let number = self.object(forKey: Constants.kReminderHour) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.intValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kReminderHour)
        }
    }
    
    var reminderDays: Int {
        get {
            guard let number = self.object(forKey: Constants.kNumberOfReminderDays) as? NSNumber
                else { fatalError("Must call configure() before accessing user defaults") }
            return number.intValue
        }
        set {
            self.set(NSNumber(value: newValue), forKey: Constants.kNumberOfReminderDays)
        }
    }
    
    func configure() {
        self.register(defaults: [
            Constants.kFirstRun : true,
            Constants.kReminderHour : 8,
            Constants.kNumberOfReminderDays : 14
        ])
    }
}

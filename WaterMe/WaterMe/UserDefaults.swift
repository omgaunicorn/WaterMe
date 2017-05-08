//
//  UserDefaults.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/7/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Constants {
        static let FirstRun = "FIRST_RUN"
        static let ReminderHour = "REMINDER_HOUR"
        static let NumberOfReminderDays = "NUMBER_OF_REMINDER_DAYS"
    }
    
    func configure() {
        self.register(defaults: [
            Constants.FirstRun : true,
            Constants.ReminderHour : 8,
            Constants.NumberOfReminderDays : 14,
        ])
    }
}

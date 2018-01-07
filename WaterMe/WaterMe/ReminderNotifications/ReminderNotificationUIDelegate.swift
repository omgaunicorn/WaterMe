//
//  ReminderNotificationUIDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 4/1/18.
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

import UserNotifications

class ReminderNotificationUIDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void)
    {
        // if the trigger is NIL that means it was fired while the app was open and its for the past
        guard notification.request.trigger != nil else {
            completionHandler([.badge])
            return
        }
        // if its not NIL that means its a scheduled notification
        // that just happened to arrive while the user is using the app
        completionHandler([.alert, .badge, .sound])
    }
}

extension UNUserNotificationCenter {
    var settings: UNNotificationSettings {
        let semaphore = DispatchSemaphore(value: 0)
        var settings: UNNotificationSettings!
        self.getNotificationSettings() { s in
            settings = s
            semaphore.signal()
        }
        semaphore.wait()
        return settings
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

//
//  NotificationSettingsChangeObserver.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/2/18.
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

import UserNotifications
import UIKit

class NotificationSettingsChangeObserver {

    var changed: (() -> Void)?
    private var previousSettings: UNNotificationSettings

    init() {
        self.previousSettings = UNUserNotificationCenter.current().settings
        NotificationCenter.default.addObserver(self, selector: #selector(self.appStateDidChange(_:)), name: .UIApplicationWillEnterForeground, object: nil)
    }

    @objc private func appStateDidChange(_ notification: Any) {
        let previousSettings = self.previousSettings
        // don't want to lock the main thread on every launch
        UNUserNotificationCenter.current().getNotificationSettings() { currentSettings in
            if previousSettings != currentSettings {
                self.changed?()
            }
            self.previousSettings = currentSettings
        }
    }
}

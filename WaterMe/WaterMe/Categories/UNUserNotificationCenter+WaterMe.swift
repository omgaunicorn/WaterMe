//
//  UNUserNotificationCenter+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2020/02/17.
//  Copyright © 2020 Saturday Apps.
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

extension UNUserNotificationCenter {
    /**
     This is a workaround for some sort of bug in `UNUserNotificationCenter`
     If the user has too many days in a row of notifications,
     when I schedule them the center accepts the addition
     with no error, then later the notifications never come.

     This value was found experimentally on iOS 13 on iPhone X.
     I'm not sure if its the same on every device though.
     70 DOES NOT WORK
     60 WORKS
     Setting at 50 because it should give enough gap
     so that things remain reliable across many devices
     while still providing good value for users.
     */
    static let notificationLimit = 50
}

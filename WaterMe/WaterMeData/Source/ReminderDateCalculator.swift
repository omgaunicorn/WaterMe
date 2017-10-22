//
//  ReminderDateCalculator.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 21/10/17.
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

import Foundation

enum ReminderDateCalculator {

    static func today(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let startOfNow = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: Calendar.Component.day, value: 1, to: now)!
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        return DateInterval(start: startOfNow, end: startOfTomorrow)
    }

}

internal extension ReminderSection {
}

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

public extension Calendar {
    public func dateWithExact(hour: Int, onSameDayAs date: Date) -> Date {
        let start = self.startOfDay(for: date)
        let interval = TimeInterval(hour * 60 * 60)
        let end = start + interval
        return end
    }
    public func dateWithExact(hour: Int, onSameDayAs date: Date?) -> Date? {
        guard let date = date else { return nil }
        let adjusted: Date = self.dateWithExact(hour: hour, onSameDayAs: date)
        return adjusted
    }
    public func endOfDay(for date: Date) -> Date {
        var addition = DateComponents()
        addition.day = 1
        let plusOneDay = self.date(byAdding: addition, to: date)!
        let startOfPlusOneDay = self.startOfDay(for: plusOneDay)
        return startOfPlusOneDay
    }
}

enum ReminderDateCalculator {

    static func late(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let beginningOfTime = Date.distantPast
        let startOfNow = calendar.startOfDay(for: now)
        return DateInterval(start: beginningOfTime, end: startOfNow)
    }

    static func today(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let startOfToday = self.late(calendar: calendar, now: now).end
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        return DateInterval(start: startOfToday, end: startOfTomorrow)
    }

    static func tomorrow(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let startOfTomorrow = self.today(calendar: calendar, now: now).end
        let startOfDayAfterTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfTomorrow)!
        return DateInterval(start: startOfTomorrow, end: startOfDayAfterTomorrow)
    }

    static func thisWeek(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let startOfDayAfterTomorrow = self.tomorrow(calendar: calendar, now: now).end
        var components = calendar.dateComponents([.weekOfYear], from: startOfDayAfterTomorrow)
        components.weekOfYear! += 1
        let startOfNextWeek = calendar.nextDate(after: startOfDayAfterTomorrow, matching: components, matchingPolicy: .nextTime)!
        return DateInterval(start: startOfDayAfterTomorrow, end: startOfNextWeek)
    }

    static func later(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let startOfNextNextWeek = self.thisWeek(calendar: calendar, now: now).end
        let endOfDays = Date.distantFuture
        return DateInterval(start: startOfNextNextWeek, end: endOfDays)
    }
}

internal extension ReminderSection {
    var dateInterval: DateInterval {
        switch self {
        case .late:
            return ReminderDateCalculator.late()
        case .today:
            return ReminderDateCalculator.today()
        case .tomorrow:
            return ReminderDateCalculator.tomorrow()
        case .thisWeek:
            return ReminderDateCalculator.thisWeek()
        case .later:
            return ReminderDateCalculator.later()
        }
    }
}

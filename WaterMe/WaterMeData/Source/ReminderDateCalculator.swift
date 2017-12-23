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
        let range = calendar.dateInterval(of: .day, for: now)!
        return range
    }

    static func tomorrow(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        var c = DateComponents()
        c.day = 1
        let tomorrow = calendar.date(byAdding: c, to: now)!
        let range = calendar.dateInterval(of: .day, for: tomorrow)!
        return range
    }

    static func thisWeek(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        // find the start of next week using NOW as the reference
        let rangeOfWeekContainingToday = calendar.dateInterval(of: .weekOfMonth, for: now)!
        let endOfWeekContainingToday = rangeOfWeekContainingToday.end
        // this is a super cheap hack to roll things in to the next unit
        let beginningOfNextWeek = endOfWeekContainingToday.addingTimeInterval(1)
        let rangeOfNextWeek = calendar.dateInterval(of: .weekOfMonth, for: beginningOfNextWeek)!
        let trueBeginningOfNextWeek = rangeOfNextWeek.start

        // find startOfDayAfterTomorrow so we don't conflict with earlier results
        let startOfDayAfterTomorrow = self.tomorrow(calendar: calendar, now: now).end

        // make sure that start of next week is after startOfDayAfterTomorrow
        if trueBeginningOfNextWeek >= startOfDayAfterTomorrow {
            return DateInterval(start: startOfDayAfterTomorrow, end: trueBeginningOfNextWeek)
        } else {
            return DateInterval(start: startOfDayAfterTomorrow, end: startOfDayAfterTomorrow)
        }
    }

    static func later(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        let startOfNextWeek = self.thisWeek(calendar: calendar, now: now).end
        let endOfDays = Date.distantFuture
        return DateInterval(start: startOfNextWeek, end: endOfDays)
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

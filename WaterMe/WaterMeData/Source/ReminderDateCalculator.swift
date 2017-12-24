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
        let plusOneDay = self.date(byAdding: .day, value: 1, to: date)!
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
        // get the range of NOW
        let range = calendar.dateInterval(of: .day, for: now)!
        // get the previous end so all values are contiguous
        let previousEnd = self.late(calendar: calendar, now: now).end

        return DateInterval(start: previousEnd, end: range.end)
    }

    static func tomorrow(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        // get tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        // get the range of tomorrow
        let range = calendar.dateInterval(of: .day, for: tomorrow)!
        // get the previous end so all values are contiguous
        let previousEnd = self.today(calendar: calendar, now: now).end

        return DateInterval(start: previousEnd, end: range.end)
    }

    static func thisWeek(calendar: Calendar = Calendar.current, now: Date = Date()) -> DateInterval {
        // find the start of next week using NOW as the reference
        let rangeOfWeekContainingToday = calendar.dateInterval(of: .weekOfMonth, for: now)!
        let endOfWeekContainingToday = rangeOfWeekContainingToday.end
        // this is a super cheap hack to roll things in to the next unit
        let beginningOfNextWeek = endOfWeekContainingToday.addingTimeInterval(1)
        let rangeOfNextWeek = calendar.dateInterval(of: .weekOfMonth, for: beginningOfNextWeek)!
        let startOfNextWeek = rangeOfNextWeek.start
        // get the previous end so all values are contiguous
        let previousEnd = self.tomorrow(calendar: calendar, now: now).end
        // make sure that start of next week is after previousEnd
        if startOfNextWeek >= previousEnd {
            return DateInterval(start: previousEnd, end: startOfNextWeek)
        } else {
            return DateInterval(start: previousEnd, end: previousEnd)
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

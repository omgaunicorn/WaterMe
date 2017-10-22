//
//  ReminderGedeg.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 19/10/17.
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

import RealmSwift
import Foundation

/**
 Contains a bunch of functions that take a collection of Reminders and produce indexpaths and vice versa
 IndexPaths represent reminders grouped by when they need to be performed next
 i.e. Today, Tomorrow, This Week, Later
 Gedeg == Grouper / Degrouper
*/

public enum ReminderGedeg {

    public static let enabled: Bool = false

    public typealias Reminders = AnyRealmCollection<Reminder>

    public static func numberOfSections(for reminders: Reminders?) -> Int? {
        guard self.enabled else { return 1 }
        return ReminderSection.count
    }

    public static func numberOfItems(inSection section: Int, for reminders: Reminders?) -> Int? {
        guard self.enabled else { return reminders?.count }
        guard let section = ReminderSection(rawValue: section) else { assertionFailure(); return nil; }
        let filtered = reminders?.filter(section.filter)
        return filtered?.count
    }

    public static func reminder(at indexPath: IndexPath, in reminders: Reminders?) -> Reminder? {
        guard self.enabled else { return reminders?[indexPath.row] }
        guard let section = ReminderSection(rawValue: indexPath.section) else { assertionFailure(); return nil; }
        let filtered = reminders?.filter(section.filter)
        let reminder = filtered?[indexPath.row]
        return reminder
    }
}

internal enum EDC /*Exhaustive Date Comparison*/ {

    internal static func f1_isBeforeToday(_ testDate: Date?, calendar: Calendar = Calendar.current, now: Date = Date()) -> Bool {
        guard let testDate = testDate, calendar.isDate(testDate, inSameDayAs: now) == false else { return false }
        return testDate < now
    }

    internal static func f2_isInToday(_ testDate: Date?, calendar: Calendar = Calendar.current, now: Date = Date()) -> Bool {
        guard let testDate = testDate, self.f1_isBeforeToday(testDate, calendar: calendar, now: now) == false else { return false }
        return calendar.isDate(testDate, inSameDayAs: now)
    }

    internal static func f3_isInTomorrow(_ testDate: Date?, calendar: Calendar = Calendar.current, now: Date = Date()) -> Bool {
        guard let testDate = testDate, self.f2_isInToday(testDate, calendar: calendar, now: now) == false else { return false }
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
        return calendar.isDate(testDate, inSameDayAs: tomorrow)
    }

    internal static func f4_isInThisWeekAndAfterTomorrow(_ testDate: Date?, calendar: Calendar = Calendar.current, now: Date = Date()) -> Bool {
        guard let testDate = testDate, self.f3_isInTomorrow(testDate, calendar: calendar, now: now) == false else { return false }
        let testDateIsInSameWeekAsNow = calendar.isDate(testDate, equalTo: now, toGranularity: .weekOfYear)
        return testDateIsInSameWeekAsNow
    }

    internal static func f5_isInNextWeek(_ testDate: Date?, calendar: Calendar = Calendar.current, now: Date = Date()) -> Bool {
        guard let testDate = testDate, self.f4_isInThisWeekAndAfterTomorrow(testDate, calendar: calendar, now: now) == false else { return false }
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now)!
        let testDateIsInSameWeekAsNextWeek = calendar.isDate(testDate, equalTo: nextWeek, toGranularity: .weekOfYear)
        return testDateIsInSameWeekAsNextWeek
    }

    internal static func f6_isNotCoveredByOthers(_ testDate: Date?, calendar: Calendar = Calendar.current, now: Date = Date()) -> Bool {
        guard let testDate = testDate, self.f5_isInNextWeek(testDate, calendar: calendar, now: now) == false else { return false }
        return true
    }
}

fileprivate extension ReminderSection {
    fileprivate var filter: (Reminder) -> Bool {
        switch self {
        case .late:
            return { $0.nextPerformDate == nil || EDC.f1_isBeforeToday($0.nextPerformDate) }
        case .today:
            return { EDC.f2_isInToday($0.nextPerformDate) }
        case .tomorrow:
            return { EDC.f3_isInTomorrow($0.nextPerformDate) }
        case .thisWeek:
            return { EDC.f4_isInThisWeekAndAfterTomorrow($0.nextPerformDate) }
        case .later:
            return { EDC.f5_isInNextWeek($0.nextPerformDate) }
        }
    }
}

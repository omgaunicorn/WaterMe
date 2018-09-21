//
//  NSFormatter+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/20/18.
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

import Foundation

extension Formatter {
    class var newReminderIntervalFormatter: DateComponentsFormatter {
        let f = DateComponentsFormatter()
        f.allowedUnits = [.month, .weekOfMonth, .day]
        f.unitsStyle = .full
        return f
    }
    class var newTimeAgoFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        f.doesRelativeDateFormatting = true
        return f
    }
    class var newDueDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        df.doesRelativeDateFormatting = true
        return df
    }
}

extension DateFormatter {
    func timeAgoString(for date: Date?) -> String {
        guard let date = date else { return ReminderMainViewController.LocalizedString.timeAgoLabelNever }
        let dateString = self.string(from: date)
        return dateString
    }
}

extension DateComponentsFormatter {
    func string(forDayInterval interval: Int) -> String {
        let time = TimeInterval(interval) * (60 * 60 * 24)
        let string = self.string(from: time)
        assert(string != nil, "Time Interval Formatter Returned NIL for Interval: \(interval)")
        return string ?? "–"
    }
}

import WaterMeData

extension ReminderVessel {
    var shortLabelSafeDisplayName: String? {
        let name = self.displayName ?? ""
        let characterLimit = 20
        guard name.count > characterLimit else { return self.displayName }
        let endIndex = name.index(name.startIndex, offsetBy: characterLimit)
        let substring = String(self.displayName![..<endIndex])
        if let trimmed = substring.nonEmptyString {
            return trimmed + "…"
        } else {
            return nil
        }
    }
}

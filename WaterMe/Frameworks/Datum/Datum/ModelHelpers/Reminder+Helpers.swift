//
//  Reminder+Helpers.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/15.
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

import Calculate

// MARK: Core Data

extension CD_Reminder {
    internal var kind: ReminderKind {
        get {
            return .init(rawValue: (self.kindString, self.descriptionString))
        }
        set {
            let raw = newValue.rawValue
            self.kindString = raw.primary
            raw.secondary.map { self.descriptionString = $0 }
        }
    }
}

extension CD_Reminder: ModelCompleteCheckable {
    internal var isModelComplete: ModelCompleteError? {
        switch self.kind {
        case .fertilize, .water, .trim, .mist:
            return nil
        case .move(let description):
            return description?.nonEmptyString == nil ?
                ModelCompleteError(_actions: [.reminderMissingMoveLocation, .cancel, .saveAnyway])
                : nil
        case .other(let description):
            return description?.nonEmptyString == nil ?
                ModelCompleteError(_actions: [.reminderMissingOtherDescription, .cancel, .saveAnyway])
                : nil
        }
    }
}

// MARK: Realm

extension RLM_Reminder {    
    internal var vessel: RLM_ReminderVessel? { return self.vessels.first }
    internal var kind: ReminderKind {
        get {
            return .init(rawValue: (self.kindString, self.descriptionString))
        }
        set {
            let raw = newValue.rawValue
            self.kindString = raw.primary
            raw.secondary.map { self.descriptionString = $0 }
        }
    }
    
    internal func recalculateNextPerformDate(comparisonPerform: RLM_ReminderPerform? = nil) {
        if let lastPerform = comparisonPerform ?? self.performed.last {
            self.nextPerformDate = lastPerform.date + TimeInterval(self.interval * 24 * 60 * 60)
        } else {
            self.nextPerformDate = nil
        }
    }
}

extension RLM_Reminder: ModelCompleteCheckable {
    internal var isModelComplete: ModelCompleteError? {
        switch self.kind {
        case .fertilize, .water, .trim, .mist:
            return nil
        case .move(let description):
            return description?.nonEmptyString == nil ?
                ModelCompleteError(_actions: [.reminderMissingMoveLocation, .cancel, .saveAnyway])
                : nil
        case .other(let description):
            return description?.nonEmptyString == nil ?
                ModelCompleteError(_actions: [.reminderMissingOtherDescription, .cancel, .saveAnyway])
                : nil
        }
    }
}

public enum ReminderSection: Int, CaseIterable {
    case late, today, tomorrow, thisWeek, later
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

public enum ReminderSortOrder {
    case nextPerformDate, interval, kind, note
}

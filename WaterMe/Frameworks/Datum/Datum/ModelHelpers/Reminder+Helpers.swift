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

extension RLM_Reminder {
    internal static let minimumInterval: Int = 1
    internal static let maximumInterval: Int = 180
    internal static let defaultInterval: Int = 7
    
    internal var vessel: RLM_ReminderVessel? { return self.vessels.first }
    internal var kind: ReminderKind {
        get { return self.kindValue }
        set { self.update(with: newValue) }
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

extension RLM_Reminder {
    
    internal static let kCaseWaterValue = "kReminderKindCaseWaterValue"
    fileprivate static let kCaseTrimValue = "kReminderKindCaseTrimValue"
    fileprivate static let kCaseMistValue = "kReminderKindCaseMistValue"
    fileprivate static let kCaseFertilizeValue = "kReminderKindCaseFertilizeValue"
    fileprivate static let kCaseMoveValue = "kReminderKindCaseMoveValue"
    fileprivate static let kCaseOtherValue = "kReminderKindCaseOtherValue"
    
    fileprivate func update(with kind: ReminderKind) {
        switch kind {
        case .water:
            self.kindString = type(of: self).kCaseWaterValue
        case .fertilize:
            self.kindString = type(of: self).kCaseFertilizeValue
        case .trim:
            self.kindString = type(of: self).kCaseTrimValue
        case .mist:
            self.kindString = type(of: self).kCaseMistValue
        case .move(let location):
            self.kindString = type(of: self).kCaseMoveValue
            self.descriptionString = location?.nonEmptyString
        case .other(let description):
            self.kindString = type(of: self).kCaseOtherValue
            self.descriptionString = description?.nonEmptyString
        }
    }
    
    fileprivate var kindValue: ReminderKind {
        switch self.kindString {
        case type(of: self).kCaseWaterValue:
            return .water
        case type(of: self).kCaseFertilizeValue:
            return .fertilize
        case type(of: self).kCaseTrimValue:
            return .trim
        case type(of: self).kCaseMistValue:
            return .mist
        case type(of: self).kCaseMoveValue:
            let description = self.descriptionString?.nonEmptyString
            return .move(location: description)
        case type(of: self).kCaseOtherValue:
            let description = self.descriptionString?.nonEmptyString
            return .other(description: description)
        default:
            fatalError("Reminder.Kind: Invalid Case String Key")
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

public enum ReminderKind: Hashable {
    case water, fertilize, trim, mist, move(location: String?), other(description: String?)
    public static let count = 6
}

public struct ReminderIdentifier: UUIDRepresentable, Hashable {
    public var reminderIdentifier: String
    // TODO: Maybe delete this init
    internal init(reminder: RLM_Reminder) {
        self.reminderIdentifier = reminder.uuid
    }
    public init(reminder: ReminderWrapper) {
        self.reminderIdentifier = reminder.uuid
    }
    public init(rawValue: String) {
        self.reminderIdentifier = rawValue
    }
    public var uuid: String { return self.reminderIdentifier }
}

public enum ReminderSortOrder {
    case nextPerformDate, interval, kind, note
    internal var keyPath: String {
        switch self {
        case .interval:
            return #keyPath(RLM_Reminder.interval)
        case .kind:
            return #keyPath(RLM_Reminder.kindString)
        case .nextPerformDate:
            return #keyPath(RLM_Reminder.nextPerformDate)
        case .note:
            return #keyPath(RLM_Reminder.note)
        }
    }
}

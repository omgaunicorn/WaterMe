//
//  Reminder.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/31/17.
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

import Result
import RealmSwift
import Foundation

public class Reminder: Object {
    
    public static let minimumInterval: Int = 1
    public static let maximumInterval: Int = 180
    public static let defaultInterval: Int = 7
    
    public enum Kind {
        case water, fertilize, move(location: String?), other(description: String?)
        public static let count = 4
    }
    
    // MARK: Public Interface
    public var kind: Kind {
        get { return self.kindValue }
        set { self.update(with: newValue) }
    }
    @objc public private(set) dynamic var uuid = UUID().uuidString
    @objc public internal(set) dynamic var interval = Reminder.defaultInterval
    @objc public internal(set) dynamic var note: String?
    @objc public internal(set) dynamic var nextPerformDate: Date?
    public let performed = List<ReminderPerform>()
    public var vessel: ReminderVessel? { return self.vessels.first }
    
    // MARK: Implementation Details
    @objc internal dynamic var kindString: String = Reminder.kCaseWaterValue
    @objc internal dynamic var descriptionString: String?
    internal let vessels = LinkingObjects(fromType: ReminderVessel.self, property: "reminders") //#keyPath(ReminderVessel.reminders)

    public override class func primaryKey() -> String {
        return #keyPath(Reminder.uuid)
    }

    internal func recalculateNextPerformDate(comparisonPerform: ReminderPerform? = nil) {
        if let lastPerform = comparisonPerform ?? self.performed.last {
            self.nextPerformDate = lastPerform.date + TimeInterval(self.interval * 24 * 60 * 60)
        } else {
            self.nextPerformDate = nil
        }
    }
}

public class ReminderPerform: Object {
    @objc public internal(set) dynamic var date = Date()
}

fileprivate extension Reminder {
    
    fileprivate static let kCaseWaterValue = "kReminderKindCaseWaterValue"
    fileprivate static let kCaseFertilizeValue = "kReminderKindCaseFertilizeValue"
    fileprivate static let kCaseMoveValue = "kReminderKindCaseMoveValue"
    fileprivate static let kCaseOtherValue = "kReminderKindCaseOtherValue"
    
    fileprivate func update(with kind: Reminder.Kind) {
        switch kind {
        case .water:
            self.kindString = type(of: self).kCaseWaterValue
        case .fertilize:
            self.kindString = type(of: self).kCaseFertilizeValue
        case .move(let location):
            self.kindString = type(of: self).kCaseMoveValue
            // check for new values to prevent being destructive
            if let location = location {
                self.descriptionString = location
            }
        case .other(let description):
            self.kindString = type(of: self).kCaseOtherValue
            // check for new values to prevent being destructive
            if let description = description {
                self.descriptionString = description
            }
        }
    }
    
    fileprivate var kindValue: Reminder.Kind {
        switch self.kindString {
        case type(of: self).kCaseWaterValue:
            return .water
        case type(of: self).kCaseFertilizeValue:
            return .fertilize
        case type(of: self).kCaseMoveValue:
            let description = self.descriptionString
            return .move(location: description)
        case type(of: self).kCaseOtherValue:
            let description = self.descriptionString
            return .other(description: description)
        default:
            fatalError("Reminder.Kind: Invalid Case String Key")
        }
    }
}

extension Reminder: UICompleteCheckable {
    
    public enum Error: UserFacingError {
        case missingMoveLocation, missingOtherDescription
        public var title: String {
            switch self {
            case .missingMoveLocation:
                return "Missing Location"
            case .missingOtherDescription:
                return "Missing Description"
            }
        }
        public var details: String? {
            return nil
        }
        public var actionTitle: String? {
            switch self {
            case .missingMoveLocation:
                return "Enter Location"
            case .missingOtherDescription:
                return "Enter Description"
            }
        }
    }
    
    public typealias E = Error
    
    public var isUIComplete: [Error] {
        switch self.kind {
        case .fertilize, .water:
            return []
        case .move(let description):
            return description?.leadingTrailingWhiteSpaceTrimmedNonEmptyString == nil ? [.missingMoveLocation] : []
        case .other(let description):
            return description?.leadingTrailingWhiteSpaceTrimmedNonEmptyString == nil ? [.missingOtherDescription] : []
        }
    }
}

public extension Reminder.Kind {
    public var stringValue: String {
        switch self {
        case .water:
            return "Water Plant"
        case .fertilize:
            return "Fertilize Soil"
        case .move:
            return "Move Plant"
        case .other:
            return "Other"
        }
    }
}

public extension Reminder {
    public struct Identifier {
        public var reminderIdentifier: String
        public init(reminder: Reminder) {
            self.reminderIdentifier = reminder.uuid
        }
    }
}

public extension Reminder {
    public enum SortOrder {
        case nextPerformDate, interval, kind, note

        internal var keyPath: String {
            switch self {
            case .interval:
                return #keyPath(Reminder.interval)
            case .kind:
                return #keyPath(Reminder.kindString)
            case .nextPerformDate:
                return #keyPath(Reminder.nextPerformDate)
            case .note:
                return #keyPath(Reminder.note)
            }
        }
    }
}

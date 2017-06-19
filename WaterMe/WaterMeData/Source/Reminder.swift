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

import RealmSwift
import Foundation

public class Reminder: Object {
    public enum Kind {
        case water, fertilize, move(location: String?), other(title: String, description: String?)
    }
    internal dynamic var kindObject: ReminderKind! = ReminderKind()
    public var kind: Kind {
        get { return self.kindObject.kindValue ?? .fertilize }
        set { self.kindObject.update(with: newValue) }
    }
    public internal(set) dynamic var interval: Int = 4
    public let performed = List<ReminderPerform>()
    internal let vessels = LinkingObjects(fromType: ReminderVessel.self, property: "reminders") //#keyPath(ReminderVessel.reminders)
    public var vessel: ReminderVessel? { return self.vessels.first }
}

public class ReminderPerform: Object {
    public internal(set) var date = Date()
}

internal class ReminderKind: Object {
    
    private static let kCaseWaterValue = "kReminderKindCaseWaterValue"
    private static let kCaseFertilizeValue = "kReminderKindCaseFertilizeValue"
    private static let kCaseMoveValue = "kReminderKindCaseMoveValue"
    private static let kCaseOtherValue = "kReminderKindCaseOtherValue"
    
    internal dynamic var kindString: String?
    internal dynamic var titleString: String?
    internal dynamic var descriptionString: String?
    
    internal func update(with kind: Reminder.Kind) {
        switch kind {
        case .water:
            self.kindString = type(of: self).kCaseWaterValue
            self.titleString = nil
            self.descriptionString = nil
        case .fertilize:
            self.kindString = type(of: self).kCaseFertilizeValue
            self.titleString = nil
            self.descriptionString = nil
        case .move(let location):
            self.kindString = type(of: self).kCaseMoveValue
            self.titleString = nil
            self.descriptionString = location
        case .other(let title, let description):
            self.kindString = type(of: self).kCaseOtherValue
            self.titleString = title
            self.descriptionString = description
        }
    }
    
    var kindValue: Reminder.Kind? {
        guard let kindString = self.kindString else {
            assertionFailure("Reminder.Kind: Kind String was NIL")
            return nil
        }
        switch kindString {
        case type(of: self).kCaseWaterValue:
            return .water
        case type(of: self).kCaseFertilizeValue:
            return .fertilize
        case type(of: self).kCaseMoveValue:
            let description = self.descriptionString
            return .move(location: description)
        case type(of: self).kCaseOtherValue:
            guard let title = self.titleString else {
                assertionFailure("Reminder.Kind.other: Missing Title")
                return nil
            }
            let description = self.descriptionString
            return .other(title: title, description: description)
        default:
            assertionFailure("Reminder.Kind: Invalid Case String Key")
            return nil
        }
    }
}

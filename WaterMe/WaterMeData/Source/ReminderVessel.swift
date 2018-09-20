//
//  ReminderVessel.swift
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
import UIKit
import RealmSwift

public enum UserFacingErrorRecoveryActions {
    case openWaterMeSettings, none
}

public protocol UserFacingError: Swift.Error {
    var title: String { get }
    var details: String? { get }
    var recoveryActions: UserFacingErrorRecoveryActions { get }
}

public protocol UICompleteCheckable {
    associatedtype E
    var isUIComplete: [E] { get }
}

public class ReminderVessel: Object {
    
    public enum Kind: String {
        case plant
    }
    
    @objc public internal(set) dynamic var uuid = UUID().uuidString
    @objc public internal(set) dynamic var displayName: String?
    public let reminders = List<Reminder>()
    
    @objc private dynamic var iconImageData: Data?
    @objc private dynamic var iconEmojiString: String?
    public internal(set) var icon: Icon? {
        get { return Icon(rawImageData: self.iconImageData, emojiString: self.iconEmojiString) }
        set {
            self.iconImageData = newValue?.dataValue
            self.iconEmojiString = newValue?.stringValue
        }
    }

    @objc internal dynamic var bloop = false
    @objc private dynamic var kindString = Kind.plant.rawValue
    public internal(set) var kind: Kind {
        get { return Kind(rawValue: self.kindString) ?? .plant }
        set { self.kindString = newValue.rawValue }
    }
    
    override public class func primaryKey() -> String {
        return #keyPath(ReminderVessel.uuid)
    }
}

extension ReminderVessel: UICompleteCheckable {
    
    public enum Error {
        case missingIcon, missingName, noReminders
    }
    
    public typealias E = Error
    
    public var isUIComplete: [Error] {
        let errors: [Error] = [
            self.icon == nil ? .missingIcon : nil,
            self.displayName == nil ? .missingName : nil,
            self.reminders.isEmpty ? .noReminders : nil
            ].compactMap({ $0 })
        return errors
    }
}

extension ReminderVessel {
    public class func propertyChangesContainDisplayName(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.displayName // here to cause a compile error if this changes
        let matches = properties.filter({ $0.name == "displayName" })
        let contains = !matches.isEmpty
        return contains
    }
    public class func propertyChangesContainIconEmoji(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.iconImageData
        _ = \ReminderVessel.iconEmojiString // here to cause a compile error if this changes
        let dataMatches = properties.filter({ $0.name == "iconImageData" })
        let emojiMatches = properties.filter({ $0.name == "iconEmojiString" })
        let contains = !dataMatches.isEmpty || !emojiMatches.isEmpty
        return contains
    }
    public class func propertyChangesContainReminders(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.reminders // here to cause a compile error if this changes
        let matches = properties.filter({ $0.name == "reminders" })
        let contains = !matches.isEmpty
        return contains
    }
    public class func propertyChangesContainPointlessBloop(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.bloop // here to cause a compile error if this changes
        let matches = properties.filter({ $0.name == "bloop" })
        let contains = !matches.isEmpty
        return contains
    }
}

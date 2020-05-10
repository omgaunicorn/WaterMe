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

import RealmSwift
import Calculate

public class ReminderVessel: Object {

    public struct Identifier: UUIDRepresentable, Hashable {
        public var reminderVesselIdentifier: String
        public init(reminderVessel: ReminderVessel) {
            self.reminderVesselIdentifier = reminderVessel.uuid
        }
        public init(rawValue: String) {
            self.reminderVesselIdentifier = rawValue
        }
        public var uuid: String { return self.reminderVesselIdentifier }
    }
    
    public enum Kind: String {
        case plant
    }
    
    @objc public internal(set) dynamic var uuid = UUID().uuidString
    @objc public internal(set) dynamic var displayName: String?
    public let reminders = List<Reminder>()
    
    @objc public private(set) dynamic var iconImageData: Data?
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

extension ReminderVessel: ModelCompleteCheckable {

    public var isModelComplete: ModelCompleteError? {
        let issues: [RecoveryAction] = [
            self.icon == nil ? .reminderVesselMissingIcon : nil,
            self.displayName == nil ? .reminderVesselMissingName : nil,
            self.reminders.isEmpty ? .reminverVesselMissingReminder : nil
            ].compactMap({ $0 })
        if issues.isEmpty {
            return nil
        } else {
            return ModelCompleteError(_actions: issues + [.cancel, .saveAnyway])
        }
    }
}

extension ReminderVessel {
    internal class func propertyChangesContainDisplayName(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.displayName // here to cause a compile error if this changes
        let matches = properties.filter({ $0.name == "displayName" })
        let contains = !matches.isEmpty
        return contains
    }
    internal class func propertyChangesContainIconEmoji(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.iconImageData
        _ = \ReminderVessel.iconEmojiString // here to cause a compile error if this changes
        let dataMatches = properties.filter({ $0.name == "iconImageData" })
        let emojiMatches = properties.filter({ $0.name == "iconEmojiString" })
        let contains = !dataMatches.isEmpty || !emojiMatches.isEmpty
        return contains
    }
    internal class func propertyChangesContainReminders(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.reminders // here to cause a compile error if this changes
        let matches = properties.filter({ $0.name == "reminders" })
        let contains = !matches.isEmpty
        return contains
    }
    internal class func propertyChangesContainPointlessBloop(_ properties: [PropertyChange]) -> Bool {
        _ = \ReminderVessel.bloop // here to cause a compile error if this changes
        let matches = properties.filter({ $0.name == "bloop" })
        let contains = !matches.isEmpty
        return contains
    }
}

extension ReminderVessel {

    public var shortLabelSafeDisplayName: String? {
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

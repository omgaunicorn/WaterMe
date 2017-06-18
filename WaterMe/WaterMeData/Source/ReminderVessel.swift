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

public class ReminderVessel: Object {
    
    public enum Kind: String {
        case plant
    }
    
    public internal(set) dynamic var uuid = UUID().uuidString
    public internal(set) dynamic var displayName: String?
    public let reminders = List<Reminder>()
    
    private dynamic var iconImageData: Data?
    private dynamic var iconEmojiString: String?
    public internal(set) var icon: Icon? {
        get { return Icon(rawImageData: self.iconImageData, emojiString: self.iconEmojiString) }
        set {
            self.iconImageData = newValue?.dataValue
            self.iconEmojiString = newValue?.stringValue
        }
    }
    
    private dynamic var kindString = Kind.plant.rawValue
    public internal(set) var kind: Kind {
        get { return Kind(rawValue: self.kindString) ?? .plant }
        set { self.kindString = newValue.rawValue }
    }
    
    override public class func primaryKey() -> String {
        return #keyPath(ReminderVessel.uuid)
    }
    
    public enum Error: Swift.Error {
        case missingIcon, missingName
    }
    
    public var isUIComplete: Result<Void, Error> {
        guard self.displayName != nil else {
            return .failure(.missingName)
        }
        guard self.icon != nil else {
            return .failure(.missingIcon)
        }
        return .success()
    }
    
}

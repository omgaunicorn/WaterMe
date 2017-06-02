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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import RealmSwift

public class ReminderVessel: Object {
    
    public struct Editable {
        public var displayName: String?
        public var icon: Icon?
        public init() {}
    }
    
    public enum Kind: String {
        case plant
    }
    
    public enum Icon {
        case emoji(String), image(Data)
    }
    
    public internal(set) dynamic var displayName = "Untitled"
    
    private dynamic var iconImageData: Data?
    private dynamic var iconEmojiString: String?
    public internal(set) var icon: Icon {
        get {
            if let image = self.iconImageData {
                return .image(image)
            } else if let string = self.iconEmojiString {
                return .emoji(string)
            } else {
                return .emoji("💀")
            }
        }
        set {
            switch newValue {
            case .emoji(let string):
                self.iconImageData = nil
                self.iconEmojiString = string
            case .image(let data):
                self.iconImageData = data
                self.iconEmojiString = nil
            }
        }
    }
    
    private dynamic var kindString = Kind.plant.rawValue
    public internal(set) var kind: Kind {
        get {
            return Kind(rawValue: self.kindString) ?? .plant
        }
        set {
            self.kindString = newValue.rawValue
        }
    }
    
    func editable() -> Editable {
        var e = Editable()
        e.displayName = self.displayName
        e.icon = self.icon
        return e
    }
    
}

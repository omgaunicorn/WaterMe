//
//  PrivateKeys.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/31/18.
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

/// Intended to be filled out by end user
/// Do not push private information into the repo
public enum PrivateKeys {
    
    public static var kRealmServer: URL {
        log.warning("Your Realm Object Server URL has not been configured.")
        fatalError("kRealmServer")
    }
    
    public static var kEmailAddress: String {
        log.warning("Your Email Address Has Not Been Configured")
        return "EMAIL-ADDRESS@NOT-YET-CONFIGURED.NOT-A-TLD"
    }
    
    public static var kEmailAddressURL: URL {
        log.warning("Your Email Address Has Not Been Configured")
        return URL(string: "mailto://" + kEmailAddress)!
    }
    
    public static func kFrabicAPIKey(isReleaseBuild: Bool) -> String? {
        return nil
    }
}

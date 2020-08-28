//
//  PrivateKeys.swift
//  Calculate
//
//  Created by Jeffrey Bergier on 2020/05/10.
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

/// Intended to be filled out by end user
/// Do not push private information into the repo
public enum PrivateKeys {

    public static var kLoggerEndpoint: URL? {
        log.warning("The endpoint used by JSBServerlessLogger goes here")
        fatalError("kLoggerEndpoint")
    }

    public static var kLoggerKey: Data {
        log.warning("The key used by JSBServerlessLogger goes here")
        fatalError("kLoggerEndpoint")
    }
    
    public static var kEmailAddress: String {
        log.warning("Your Email Address Has Not Been Configured")
        return "EMAIL-ADDRESS@NOT-YET-CONFIGURED.NOT-A-TLD"
    }
    
    public static var kEmailAddressURL: URL {
        log.warning("Your Email Address Has Not Been Configured")
        return URL(string: "mailto://" + kEmailAddress)!
    }
    
    public static var kConsumableTipJar: (small: String, medium: String, large: String)? {
        log.warning("These are the IAP product identifiers for the Tip Jar.")
        return nil
    }
    
    
    private static var kWaterMeAppStoreUUID: String {
        fatalError("You Need your own Store UUID")
    }
    
    public static var kAppStoreURL: URL? {
        log.warning("This is a URL that points to the App Store link of the app.")
        return nil
    }
    
    public static var kReviewAppURL: URL? {
        log.warning("This is a URL that points to the App Store link of the app. With write-review appended.")
        return nil
    }
    
    public static var kAppInfoJSONURL: URL? {
        log.warning("This is a URL that points to the JSON URL of the App Listing on iTunes")
        return nil
    }
    
    public static var kAvatarURL: URL? {
        log.warning("This is a URL that points to the image of the developer.")
        return nil
    }
}

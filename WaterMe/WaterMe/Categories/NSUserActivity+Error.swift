//
//  NSUserActivity+Error.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/7/18.
//  Copyright © 2018 Saturday Apps.
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

import WaterMeData
import Foundation

public enum UserActivityError: Error {
    case restorationFailed, reminderNotFound, reminderVesselNotFound, continuationFailed
}

extension UserActivityError: UserFacingError {

    public var title: String? {
        switch self {
        case .continuationFailed, .restorationFailed:
            return nil
        case .reminderNotFound:
            return "Reminder Not Found"
        case .reminderVesselNotFound:
            return "Plant Not Found"
        }
    }

    public var message: String? {
        switch self {
        case .continuationFailed, .restorationFailed:
            return "There was an error executing this Siri Shortcut. If you see this error repeatedly, it may help to delete and re-create this shortcut."
        case .reminderNotFound:
            return "The reminder for this Siri Shortcut could not be found. You may want to delete this Siri Shortcut."
        case .reminderVesselNotFound:
            return "The plant for this Siri Shortcut could not be found. You may want to delete this Siri Shortcut."
        }
    }
    
    public var recoveryActions: [RecoveryAction] {
        return [.dismiss, .openWaterMeSettings]
    }
}

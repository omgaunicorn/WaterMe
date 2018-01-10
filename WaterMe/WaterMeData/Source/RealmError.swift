//
//  RealmError.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 8/12/17.
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

import Foundation

public enum RealmError: Error {
    case loadError, createError, writeError, readError, objectDeleted, unableToDeleteLastReminder, imageCouldntBeCompressedEnough
}

extension RealmError: UserFacingError {
    public var title: String {
        switch self {
        case .unableToDeleteLastReminder:
            return "Error Deleting"
        case .loadError:
            return "Error Loading"
        case .imageCouldntBeCompressedEnough:
            return "Error Saving Image"
        default:
            return "Error Saving"
        }
    }
    public var details: String? {
        switch self {
        case .imageCouldntBeCompressedEnough:
            return "The selected image couldn't be saved. Please choose a different image or an emoji."
        case .objectDeleted:
            return "Unable to save changes because the item was deleted. Possibly from another device."
        case .createError:
            return "Error creating save file. Check to make sure there is free space available on this device."
        case .loadError:
            return "Error loading save file. Check to make sure there is free space available on this device."
        case .readError:
            return "Error reading from save file. Check to make sure there is free space available on this device."
        case .writeError:
            return "Error saving changes. Check to make sure there is free space available on this device."
        case .unableToDeleteLastReminder:
            return "Unable to delete this reminder because its the only reminder for this plant. Each plant must have at least one reminder."
        }
    }
    public var actionTitle: String? {
        switch self {
        case .objectDeleted, .unableToDeleteLastReminder, .imageCouldntBeCompressedEnough:
            return nil
        default:
            return "Manage Storage"
        }
    }
}

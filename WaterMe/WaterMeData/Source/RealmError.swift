//
//  RealmError.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 8/12/17.
//

import Foundation

public enum RealmError: Error {
    case loadError, createError, writeError, readError, objectDeleted, unableToDeleteLastReminder
}

extension RealmError: UserFacingError {
    public var title: String {
        switch self {
        case .unableToDeleteLastReminder:
            return "Error Deleting"
        case .loadError:
            return "Error Loading"
        default:
            return "Error Saving"
        }
    }
    public var details: String? {
        switch self {
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
        case .objectDeleted, .unableToDeleteLastReminder:
            return nil
        default:
            return "Manage Storage"
        }
    }
}

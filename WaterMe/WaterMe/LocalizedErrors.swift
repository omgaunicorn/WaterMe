//
//  LocalizedErrors.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 16/1/18.
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

import WaterMeData

extension RealmError: UserFacingError {

    public var title: String {
        switch self {
        case .unableToDeleteLastReminder:
            return LocalizedString.deleteTitle
        case .loadError:
            return LocalizedString.loadTitle
        case .imageCouldntBeCompressedEnough:
            return LocalizedString.saveImageTitle
        default:
            return LocalizedString.saveTitle
        }
    }

    public var details: String? {
        switch self {
        case .imageCouldntBeCompressedEnough:
            return LocalizedString.saveImageMessage
        case .objectDeleted:
            return LocalizedString.objectDeletedMessage
        case .loadError, .readError:
            return LocalizedString.loadMessage
        case .writeError, .createError:
            return LocalizedString.saveMessage
        case .unableToDeleteLastReminder:
            return LocalizedString.deleteMessage
        }
    }

    public var actionTitle: String? {
        switch self {
        case .objectDeleted, .unableToDeleteLastReminder, .imageCouldntBeCompressedEnough:
            return nil
        case .createError, .loadError, .readError, .writeError:
            return LocalizedString.buttonTitleManageStorage
        }
    }
}

extension ReminderVessel.Error: UserFacingError {
    public var title: String {
        switch self {
        case .missingIcon:
            return LocalizedString.missingPhoto
        case .missingName:
            return LocalizedString.missingName
        case .noReminders:
            return LocalizedString.missingReminders
        }
    }
    public var details: String? {
        return nil
    }
    public var actionTitle: String? {
        return nil
    }
}

extension Reminder.Error: UserFacingError {
    public var title: String {
        switch self {
        case .missingMoveLocation:
            return LocalizedString.missingLocation
        case .missingOtherDescription:
            return LocalizedString.missingDescription
        }
    }
    public var details: String? {
        return nil
    }
    public var actionTitle: String? {
        return nil
    }
}

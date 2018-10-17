//
//  NSUserActivity+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/23/18.
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
import Result
import Intents
import CoreSpotlight
import MobileCoreServices

typealias NSUserActivityContinuedHandler = ([Any]?) -> Void

public enum RestoredUserActivity {
    case editReminder(Reminder.Identifier)
    case editReminderVessel(ReminderVessel.Identifier)
    case viewReminder(Reminder.Identifier)
    case performReminder(Reminder.Identifier)
}

public enum RawUserActivity: String {
    case editReminder = "com.saturdayapps.waterme.activity.edit.reminder"
    case editReminderVessel = "com.saturdayapps.waterme.activity.edit.remindervessel"
    case viewReminder = "com.saturdayapps.waterme.activity.view.reminder"
    case performReminders = "com.saturdayapps.waterme.activity.perform.reminder"
    case indexedItem = "com.apple.corespotlightitem" //CSSearchableItemActionType
}

public extension NSUserActivity {

    fileprivate static let stringSeparator = "::"

    public static func uniqueString(for rawActivity: RawUserActivity,
                                    and uuids: [UUIDRepresentable]) -> String
    {
        let uuids = uuids.sorted(by: { $0.uuid <= $1.uuid })
        return uuids.reduce(rawActivity.rawValue) { prevValue, item -> String in
            return prevValue + stringSeparator + item.uuid
        }
    }

    public static func deuniqueString(fromRawString rawString: String) -> (String, [String])? {
        let components = rawString.components(separatedBy: self.stringSeparator)
        let _first = components.first
        let rest = components.dropFirst()
        guard let first = _first else { return nil }
        return (first, Array(rest))
    }

    public var restoredUserActivityResult: Result<RestoredUserActivity, UserActivityError> {
        guard
            let rawString = self.userInfo?[CSSearchableItemActivityIdentifier] as? String,
            let (rawValue, uuids) = type(of: self).deuniqueString(fromRawString: rawString),
            let uuid = uuids.first,
            let kind = RawUserActivity(rawValue: rawValue)
        else {
            assertionFailure()
            return .failure(.restorationFailed)
        }
        switch kind {
        case .editReminder:
            return .success(.editReminder(.init(rawValue: uuid)))
        case .editReminderVessel:
            return .success(.editReminderVessel(.init(rawValue: uuid)))
        case .viewReminder:
            return .success(.viewReminder(.init(rawValue: uuid)))
        case .performReminders:
            return .success(.performReminder(.init(rawValue: uuid)))
        case .indexedItem:
            assertionFailure("Unimplmented")
            return .failure(.restorationFailed)
        }
    }

    public convenience init(kind: RawUserActivity, delegate: NSUserActivityDelegate) {
        self.init(activityType: kind.rawValue)
        self.delegate = delegate
        self.isEligibleForHandoff = true
        self.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            self.isEligibleForPrediction = true
        }
    }

    public func update(uuid: UUIDRepresentable,
                       title: String,
                       phrase: String,
                       description: String,
                       thumbnailData: Data?)
    {
        guard let kind = RawUserActivity(rawValue: self.activityType) else {
            assertionFailure()
            return
        }
        let persistentIdentifier = type(of: self).uniqueString(for: kind, and: [uuid])
        self.title = title
        if #available(iOS 12.0, *) {
            self.suggestedInvocationPhrase = phrase
            self.persistentIdentifier = persistentIdentifier
        }
        self.addUserInfoEntries(from: [CSSearchableItemActivityIdentifier: persistentIdentifier])
        self.requiredUserInfoKeys = [CSSearchableItemActivityIdentifier]
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.relatedUniqueIdentifier = persistentIdentifier
        attributes.contentDescription = description
        attributes.thumbnailData = thumbnailData
        self.contentAttributeSet = attributes
    }
}

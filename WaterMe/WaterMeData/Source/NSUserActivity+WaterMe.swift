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

import MobileCoreServices
import CoreSpotlight
import Intents

public enum RestoredUserActivity {
    case editReminder(Reminder.Identifier)
    case editReminderVessel(ReminderVessel.Identifier)
    case viewReminder(Reminder.Identifier)
    case viewReminders
    case error
}

public enum RawUserActivity: String {
    case editReminder = "com.saturdayapps.waterme.activity.edit.reminder"
    case editReminderVessel = "com.saturdayapps.waterme.activity.edit.remindervessel"
    case viewReminder = "com.saturdayapps.waterme.activity.view.reminder"
    case viewReminders = "com.saturdayapps.waterme.activity.view.reminders"
    case indexedItem = "com.apple.corespotlightitem" //CSSearchableItemActionType
}

public extension NSUserActivity {

    fileprivate static let stringSeparator = "::"

    public static func uniqueString(for rawActivity: RawUserActivity,
                                    and uuids: [UUIDRepresentable]) -> String
    {
        return uuids.reduce(rawActivity.rawValue) { prevValue, item -> String in
            return prevValue + stringSeparator + item.uuid
        }
    }

    public var restoredUserActivity: RestoredUserActivity? {
        let rawString = self.userInfo?[CSSearchableItemActivityIdentifier] as? String
        guard
            let components = rawString?.components(separatedBy: type(of: self).stringSeparator),
            let rawValue = components.first,
            let kind = RawUserActivity(rawValue: rawValue)
        else {
            assertionFailure()
            return nil
        }
        let uuids = components.dropFirst()
        switch kind {
        case .editReminder:
            guard let uuid = uuids.first else { return nil }
            return .editReminder(.init(rawValue: uuid))
        case .editReminderVessel:
            guard let uuid = uuids.first else { return nil }
            return .editReminderVessel(.init(rawValue: uuid))
        case .viewReminder:
            guard let uuid = uuids.first else { return nil }
            return .viewReminder(.init(rawValue: uuid))
        case .viewReminders:
            guard uuids.isEmpty else { return nil }
            return .viewReminders
        case .indexedItem:
            assertionFailure("Unimplmented")
            return nil
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

    public func update(uuids: [UUIDRepresentable],
                       title: String,
                       phrase: String,
                       description: String,
                       thumbnailData: Data?)
    {
        guard let kind = RawUserActivity(rawValue: self.activityType) else {
            assertionFailure()
            return
        }
        let persistentIdentifier = type(of: self).uniqueString(for: kind, and: uuids)
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

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
import MobileCoreServices
import CoreSpotlight
import Intents

enum RestoredUserActivity {
    case editReminder(Reminder.Identifier)
    case editReminderVessel(Reminder.Identifier)
    case viewReminder(Reminder.Identifier)
    case viewReminders
    case error
}

extension NSUserActivity {

    enum Kind: String {
        case editReminder = "com.saturdayapps.waterme.activity.edit.reminder"
        case editReminderVessel = "com.saturdayapps.waterme.activity.edit.remindervessel"
        case viewReminder = "com.saturdayapps.waterme.activity.view.reminder"
        case viewReminders = "com.saturdayapps.waterme.activity.view.reminders"
    }

    var restoredUserActivity: RestoredUserActivity? {
        guard let kind = Kind(rawValue: self.activityType) else {
            assertionFailure()
            return nil
        }
        let uuid = self.userInfo?[self.activityType] as? String
        switch kind {
        case .editReminder:
            guard let uuid = uuid else { return nil }
            return .editReminder(.init(rawValue: uuid))
        case .editReminderVessel:
            guard let uuid = uuid else { return nil }
            return .editReminderVessel(.init(rawValue: uuid))
        case .viewReminder:
            guard let uuid = uuid else { return nil }
            return .viewReminder(.init(rawValue: uuid))
        case .viewReminders:
            return .viewReminders
        }
    }

    convenience init(kind: Kind, delegate: NSUserActivityDelegate) {
        self.init(activityType: kind.rawValue)
        self.delegate = delegate
        self.isEligibleForHandoff = true
        self.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            self.isEligibleForPrediction = true
        }
    }

    func update(uuid: String, title: String, phrase: String, description: String) {
        let persistentIdentifier = self.activityType + "::" + uuid
        self.title = title
        if #available(iOS 12.0, *) {
            self.suggestedInvocationPhrase = phrase
            self.persistentIdentifier = persistentIdentifier
        }
        self.requiredUserInfoKeys = [self.activityType]
        self.addUserInfoEntries(from: [self.activityType: uuid])
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.relatedUniqueIdentifier = persistentIdentifier
        attributes.contentDescription = description
        self.contentAttributeSet = attributes
    }
}

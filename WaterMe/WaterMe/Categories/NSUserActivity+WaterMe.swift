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

extension NSUserActivity {
    enum Kind: String {
//        <key>NSUserActivityTypes</key>
//        <array>
//        <string>com.saturdayapps.waterme.activity.edit.reminder</string>
//        <string>com.saturdayapps.waterme.activity.edit.remindervessel</string>
//        <string>com.saturdayapps.waterme.activity.view.reminder</string>
//        <string>com.saturdayapps.waterme.activity.edit.remindervessel.icon</string>
//        <string>com.saturdayapps.waterme.activity.edit.remindervessel.icon.camera</string>
//        <string>com.saturdayapps.waterme.activity.edit.remindervessel.icon.library</string>
//        <string>com.saturdayapps.waterme.activity.edit.remindervessel.icon.emoji</string>
//        </array>
        case editReminder = "com.saturdayapps.waterme.activity.edit.reminder"
        case editReminderVessel = "com.saturdayapps.waterme.activity.edit.remindervessel"
        case viewReminder = "com.saturdayapps.waterme.activity.view.reminder"
        case viewReminders = "com.saturdayapps.waterme.activity.view.reminders"
        case editReminderVesselIcon = "com.saturdayapps.waterme.activity.edit.remindervessel.icon"
        case editReminderVesselIconCamera = "com.saturdayapps.waterme.activity.edit.remindervessel.icon.camera"
        case editReminderVesselIconLibrary = "com.saturdayapps.waterme.activity.edit.remindervessel.icon.library"
        case editReminderVesselIconEmoji = "com.saturdayapps.waterme.activity.edit.remindervessel.icon.emoji"
    }

    convenience init(kind: Kind) {
        self.init(activityType: kind.rawValue)
        self.isEligibleForHandoff = true
        self.isEligibleForSearch = true
        if #available(iOS 12.0, *) {
            self.isEligibleForPrediction = true
        }
        self.needsSave = true
    }
}

extension ReminderVesselEditViewController {
    override func updateUserActivityState(_ activity: NSUserActivity) {
        print("ReminderVesselEditViewController: updateUserActivityState:")
        defer { super.updateUserActivityState(activity) }
        guard #available(iOS 12.0, *) else { return }
        guard let reminderVessel = self.vesselResult?.value else { return }
        let uuid = reminderVessel.uuid
        let vesselName = reminderVessel.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "Edit “%@”", vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Change your plant's name, photo, and reminders.") as String
        activity.title = title
        activity.suggestedInvocationPhrase = title
        activity.persistentIdentifier = uuid
        activity.requiredUserInfoKeys = [activity.activityType]
        activity.addUserInfoEntries(from: [activity.activityType: uuid])
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.relatedUniqueIdentifier = uuid
        attributes.contentDescription = description
        activity.contentAttributeSet = attributes
    }
}

extension ReminderMainViewController {
    override func updateUserActivityState(_ activity: NSUserActivity) {
        print("ReminderMainViewController: updateUserActivityState:")
        defer { super.updateUserActivityState(activity) }
        guard #available(iOS 12.0, *) else { return }

        let uuid = String(describing: ReminderMainViewController.self)
        let title = NSString.deferredLocalizedIntentsString(with: "View all reminders.") as String
        let phrase = NSString.deferredLocalizedIntentsString(with: "Garden Time") as String
        let description = NSString.deferredLocalizedIntentsString(with: "Manage all of your plants and reminders in WaterMe") as String
        activity.title = title
        activity.suggestedInvocationPhrase = phrase
        activity.persistentIdentifier = uuid
        activity.requiredUserInfoKeys = [activity.activityType]
        activity.addUserInfoEntries(from: [activity.activityType: uuid])
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.relatedUniqueIdentifier = uuid
        attributes.contentDescription = description
        activity.contentAttributeSet = attributes
    }
}

extension ReminderSummaryViewController: NSUserActivityDelegate {
    override func updateUserActivityState(_ activity: NSUserActivity) {
        print("ReminderSummaryViewController: updateUserActivityState:")
        defer { super.updateUserActivityState(activity) }
        guard #available(iOS 12.0, *) else { return }

        guard let reminder = self.reminderResult.value else { return }
        let uuid = reminder.uuid
        let vesselName = reminder.vessel?.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "View %@ “%@” reminder", reminder.kind.localizedShortString, vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Mark the reminder as done, edit your plant, or edit your reminder.") as String
        activity.title = title
        activity.suggestedInvocationPhrase = title
        activity.persistentIdentifier = uuid
        activity.requiredUserInfoKeys = [activity.activityType]
        activity.addUserInfoEntries(from: [activity.activityType: uuid])
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.relatedUniqueIdentifier = uuid
        attributes.contentDescription = description
        activity.contentAttributeSet = attributes
    }
}

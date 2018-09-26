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
    case editReminderVesselIcon(Reminder.Identifier)
    case editReminderVesselIconCamera(Reminder.Identifier)
    case editReminderVesselIconLibrary(Reminder.Identifier)
    case editReminderVesselIconEmoji(Reminder.Identifier)
    case error
}

extension NSUserActivity {
    enum Kind: String {
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
        case .editReminderVesselIcon:
            guard let uuid = uuid else { return nil }
            return .editReminderVesselIcon(.init(rawValue: uuid))
        case .editReminderVesselIconCamera:
            guard let uuid = uuid else { return nil }
            return .editReminderVesselIconCamera(.init(rawValue: uuid))
        case .editReminderVesselIconEmoji:
            guard let uuid = uuid else { return nil }
            return .editReminderVesselIconEmoji(.init(rawValue: uuid))
        case .editReminderVesselIconLibrary:
            guard let uuid = uuid else { return nil }
            return .editReminderVesselIconLibrary(.init(rawValue: uuid))
        case .viewReminder:
            guard let uuid = uuid else { return nil }
            return .viewReminder(.init(rawValue: uuid))
        case .viewReminders:
            return .viewReminders
        }
    }

    func update(uuid: String, title: String, phrase: String, description: String) {
        self.title = title
        if #available(iOS 12.0, *) {
            self.suggestedInvocationPhrase = phrase
            self.persistentIdentifier = uuid
        }
        self.requiredUserInfoKeys = [self.activityType]
        self.addUserInfoEntries(from: [self.activityType: uuid])
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        attributes.relatedUniqueIdentifier = uuid
        attributes.contentDescription = description
        self.contentAttributeSet = attributes
    }
}

extension ReminderVesselEditViewController {
    override func updateUserActivityState(_ activity: NSUserActivity) {
        assert(activity.activityType == NSUserActivity.Kind.editReminderVessel.rawValue)
        print("ReminderVesselEditViewController: updateUserActivityState:")
        guard #available(iOS 12.0, *) else { return }

        guard let reminderVessel = self.vesselResult?.value else { return }
        let uuid = reminderVessel.uuid
        let vesselName = reminderVessel.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "Edit “%@”", vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Change your plant's name, photo, and reminders.") as String

        activity.update(uuid: uuid, title: title, phrase: title, description: description)
        super.updateUserActivityState(activity)
    }
}

extension ReminderMainViewController {
    override func updateUserActivityState(_ activity: NSUserActivity) {
        assert(activity.activityType == NSUserActivity.Kind.viewReminders.rawValue)
        print("ReminderMainViewController: updateUserActivityState:")
        guard #available(iOS 12.0, *) else { return }

        let uuid = String(describing: ReminderMainViewController.self)
        let title = NSString.deferredLocalizedIntentsString(with: "View all reminders") as String
        let phrase = NSString.deferredLocalizedIntentsString(with: "Garden Time") as String
        let description = NSString.deferredLocalizedIntentsString(with: "Manage all of your plants and reminders in WaterMe") as String

        activity.update(uuid: uuid, title: title, phrase: phrase, description: description)
        super.updateUserActivityState(activity)
    }
}

extension ReminderSummaryViewController: NSUserActivityDelegate {
    override func updateUserActivityState(_ activity: NSUserActivity) {
        assert(activity.activityType == NSUserActivity.Kind.viewReminder.rawValue)
        print("ReminderSummaryViewController: updateUserActivityState:")
        guard #available(iOS 12.0, *) else { return }

        guard let reminder = self.reminderResult.value else { return }
        let uuid = reminder.uuid
        let vesselName = reminder.vessel?.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "View %@ “%@” reminder", reminder.kind.localizedShortString, vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Mark the reminder as done, edit your plant, or edit your reminder.") as String

        activity.update(uuid: uuid, title: title, phrase: title, description: description)
        super.updateUserActivityState(activity)
    }
}

extension ReminderEditViewController: NSUserActivityDelegate {
    override func updateUserActivityState(_ activity: NSUserActivity) {
        assert(activity.activityType == NSUserActivity.Kind.editReminder.rawValue)
        print("ReminderEditViewController: updateUserActivityState:")
        guard #available(iOS 12.0, *) else { return }

        guard let reminder = self.reminderResult?.value else { return }
        let uuid = reminder.uuid
        let vesselName = reminder.vessel?.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "Edit the %@ “%@” reminder", reminder.kind.localizedShortString, vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Change how often or the kind of reminder in WaterMe.") as String

        activity.update(uuid: uuid, title: title, phrase: title, description: description)
        super.updateUserActivityState(activity)
    }
}

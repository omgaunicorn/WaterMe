//
//  UserActivityConfigurator.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/29/18.
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

protocol UserActivityConfiguratorProtocol: NSUserActivityDelegate {
    var currentReminder: (() -> Reminder?)? { get set }
    var currentReminderVessel: (() -> ReminderVessel?)? { get set }
}

class UserActivityConfigurator: NSObject, UserActivityConfiguratorProtocol {
    var currentReminder: (() -> Reminder?)?
    var currentReminderVessel: (() -> ReminderVessel?)?
}

extension UserActivityConfigurator: NSUserActivityDelegate {
    func userActivityWillSave(_ activity: NSUserActivity) {
        let workItem = {
            guard let kind = RawUserActivity(rawValue: activity.activityType) else {
                assertionFailure("Unsupported User Activity Type")
                return
            }
            switch kind {
            case .viewReminders:
                self.updateViewReminders(activity: activity)
            case .editReminderVessel:
                guard let reminderVessel = self.currentReminderVessel?() else {
                    assertionFailure("Missing Reminder Vessel")
                    return
                }
                self.updateEditReminderVessel(activity: activity,
                                              reminderVessel: reminderVessel)
            case .editReminder:
                guard let reminder = self.currentReminder?() else {
                    assertionFailure("Missing Reminder")
                    return
                }
                self.updateEditReminder(activity: activity, reminder: reminder)
            case .viewReminder:
                guard let reminder = self.currentReminder?() else {
                    assertionFailure("Missing Reminder")
                    return
                }
                self.updateViewReminder(activity: activity, reminder: reminder)
            case .indexedItem:
                assertionFailure("Cannot update the data on a CoreSpotlight activity")
            }
        }
        if Thread.isMainThread {
            workItem()
        } else {
            DispatchQueue.main.sync() {
                workItem()
            }
        }
    }
}

private extension UserActivityConfigurator {
    private func updateEditReminderVessel(activity: NSUserActivity, reminderVessel: ReminderVessel) {
        assert(activity.activityType == RawUserActivity.editReminderVessel.rawValue)
        log.debug()
        guard #available(iOS 12.0, *) else { return }

        let uuid = reminderVessel.uuid
        let vesselName = reminderVessel.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "Edit “%@”", vesselName) as String
        let phrase = NSString.deferredLocalizedIntentsString(with: "Edit %@", vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Change your plant's name, photo, and reminders.") as String

        activity.update(uuid: uuid, title: title, phrase: phrase, description: description)
    }

    private func updateViewReminders(activity: NSUserActivity) {
        assert(activity.activityType == RawUserActivity.viewReminders.rawValue)
        log.debug()
        guard #available(iOS 12.0, *) else { return }

        let uuid = String(describing: ReminderMainViewController.self)
        let title = NSString.deferredLocalizedIntentsString(with: "View all reminders") as String
        let phrase = NSString.deferredLocalizedIntentsString(with: "Garden Time") as String
        let description = NSString.deferredLocalizedIntentsString(with: "Manage all of your plants and reminders in WaterMe") as String

        activity.update(uuid: uuid, title: title, phrase: phrase, description: description)
    }

    private func updateViewReminder(activity: NSUserActivity, reminder: Reminder) {
        assert(activity.activityType == RawUserActivity.viewReminder.rawValue)
        log.debug()
        guard #available(iOS 12.0, *) else { return }

        let uuid = reminder.uuid
        let vesselName = reminder.vessel?.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "View %@ “%@” reminder", reminder.kind.localizedShortString, vesselName) as String
        let phrase = NSString.deferredLocalizedIntentsString(with: "View notes for %@", vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Mark the reminder as done, edit your plant, or edit your reminder.") as String

        activity.update(uuid: uuid, title: title, phrase: phrase, description: description)
    }

    private func updateEditReminder(activity: NSUserActivity, reminder: Reminder) {
        assert(activity.activityType == RawUserActivity.editReminder.rawValue)
        log.debug()
        guard #available(iOS 12.0, *) else { return }

        let uuid = reminder.uuid
        let vesselName = reminder.vessel?.displayName ?? ReminderVessel.LocalizedString.untitledPlant
        let title = NSString.deferredLocalizedIntentsString(with: "Edit the %@ “%@” reminder", reminder.kind.localizedShortString, vesselName) as String
        let description = NSString.deferredLocalizedIntentsString(with: "Change how often or the kind of reminder in WaterMe.") as String

        activity.update(uuid: uuid, title: title, phrase: title, description: description)
    }
}

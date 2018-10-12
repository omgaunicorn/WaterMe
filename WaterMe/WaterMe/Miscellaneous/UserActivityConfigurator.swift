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
            case .performReminders:
                guard let reminder = self.currentReminder?() else {
                    assertionFailure("Missing Reminder")
                    return
                }
                self.updatePerformReminders(activity: activity, reminders: [reminder])
            case .indexedItem:
                assertionFailure("Cannot update the data on a CoreSpotlight activity")
            }
        }
        guard DispatchQueue.isMain == false else {
            assertionFailure("this is unexpected")
            workItem()
            return
        }
        DispatchQueue.main.sync() {
            workItem()
        }
    }
}

private extension UserActivityConfigurator {

    private func updateEditReminderVessel(activity: NSUserActivity, reminderVessel: ReminderVessel) {
        assert(activity.activityType == RawUserActivity.editReminderVessel.rawValue)

        let uuid = ReminderVessel.Identifier(reminderVessel: reminderVessel)
        let title = LocalizedString.title(fromVesselName: reminderVessel.shortLabelSafeDisplayName)
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.editReminderVesselDescription

        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: reminderVessel.iconImageData)
    }

    private func updateViewReminders(activity: NSUserActivity) {
        assert(activity.activityType == RawUserActivity.viewReminders.rawValue)

        let title = LocalizedString.viewRemindersTitle
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.viewRemindersDescriptions

        activity.update(uuids: [],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: nil)
    }

    private func updateViewReminder(activity: NSUserActivity, reminder: Reminder) {
        assert(activity.activityType == RawUserActivity.viewReminder.rawValue)

        let uuid = Reminder.Identifier(reminder: reminder)
        let title = LocalizedString.title(for: reminder.kind,
                                          andVesselName: reminder.vessel?.shortLabelSafeDisplayName)
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.viewReminderDescription

        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: reminder.vessel?.iconImageData)
    }

    private func updatePerformReminders(activity: NSUserActivity, reminders: [Reminder]) {
        assert(activity.activityType == RawUserActivity.performReminders.rawValue)
        guard reminders.isEmpty == false else {
            assertionFailure()
            return
        }

        let uuids = reminders.map({ Reminder.Identifier(reminder: $0) })
        let title: String
        let description: String
        if reminders.count >= 2 {
            // Plural
            // FIXME:
            title = "Mark \(reminders.count) as done."
            description = "Mark all of these reminders as done."
        } else {
            // Singular
            let reminder = reminders.first!
            title = LocalizedString.title(for: reminder.kind,
                                          andVesselName: reminder.vessel?.shortLabelSafeDisplayName)
            // FIXME:
            description = "Mark this reminder as done."
        }
        let phrase = LocalizedString.genericLocalizedPhrase

        activity.update(uuids: uuids,
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: reminders.first?.vessel?.iconImageData)
    }

    private func updateEditReminder(activity: NSUserActivity, reminder: Reminder) {
        assert(activity.activityType == RawUserActivity.editReminder.rawValue)

        let uuid = Reminder.Identifier(reminder: reminder)
        let title = LocalizedString.title(for: reminder.kind,
                                          andVesselName: reminder.vessel?.shortLabelSafeDisplayName)
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.editReminderDescription

        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: reminder.vessel?.iconImageData)
    }
}

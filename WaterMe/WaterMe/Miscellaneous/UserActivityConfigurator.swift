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
    var currentReminderAndVessel: (() -> ReminderAndVesselValue?)? { get set }
    var currentReminderVessel: (() -> ReminderVesselValue?)? { get set }
    var remindersForDragSession: [Reminder.Identifier]? { get set }
    var requiresMainThreadExecution: Bool { get set }
}

class UserActivityConfigurator: NSObject, UserActivityConfiguratorProtocol {
    var currentReminderAndVessel: (() -> ReminderAndVesselValue?)?
    var currentReminderVessel: (() -> ReminderVesselValue?)?
    var remindersForDragSession: [Reminder.Identifier]?
    var requiresMainThreadExecution = true
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
                guard let value = self.currentReminderAndVessel?() else {
                    assertionFailure("Missing Reminder")
                    return
                }
                self.updateEditReminder(activity: activity, value: value)
            case .viewReminder:
                guard let value = self.currentReminderAndVessel?() else {
                    assertionFailure("Missing Reminder")
                    return
                }
                self.updateViewReminder(activity: activity, value: value)
            case .performReminders:
                if let uuids = self.remindersForDragSession, uuids.isEmpty == false {
                    self.updatePerformMultipleReminders(activity: activity,
                                                        reminders: uuids)
                    self.remindersForDragSession = nil
                } else if let value = self.currentReminderAndVessel?() {
                    self.updatePerformSingleReminder(activity: activity,
                                                     value: value)
                } else {
                    assertionFailure("Missing Reminders")
                }
            case .indexedItem:
                assertionFailure("Cannot update the data on a CoreSpotlight activity")
            }
        }
        if self.requiresMainThreadExecution {
            if DispatchQueue.isMain {
                workItem()
                return
            } else {
                DispatchQueue.main.sync() {
                    workItem()
                    return
                }
            }
        } else {
            workItem()
            return
        }
    }
}

private extension UserActivityConfigurator {

    private func updateEditReminderVessel(activity: NSUserActivity, reminderVessel: ReminderVesselValue) {
        assert(activity.activityType == RawUserActivity.editReminderVessel.rawValue)

        let uuid = ReminderVessel.Identifier(rawValue: reminderVessel.uuid)
        let title = LocalizedString.editVesselTitle(fromVesselName: reminderVessel.name)
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.editReminderVesselDescription

        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: reminderVessel.imageData)
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

    private func updateViewReminder(activity: NSUserActivity, value: ReminderAndVesselValue) {
        assert(activity.activityType == RawUserActivity.viewReminder.rawValue)

        let uuid = Reminder.Identifier(rawValue: value.reminder.uuid)
        let title = LocalizedString.viewReminderTitle(for: value.reminder.kind,
                                                      andVesselName: value.reminderVessel.name)
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.viewReminderDescription

        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: value.reminderVessel.imageData)
    }

    private func updatePerformMultipleReminders(activity: NSUserActivity,
                                                reminders: [Reminder.Identifier])
    {
        assert(activity.activityType == RawUserActivity.performReminders.rawValue)

        // FIXME:
        let title = "Mark \(reminders.count) as done."
        // FIXME:
        let description = "Mark all of these reminders as done."
        let phrase = LocalizedString.genericLocalizedPhrase

        activity.update(uuids: reminders,
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: nil)
    }

    private func updatePerformSingleReminder(activity: NSUserActivity,
                                             value: ReminderAndVesselValue)
    {
        assert(activity.activityType == RawUserActivity.performReminders.rawValue)

        let uuid = Reminder.Identifier(rawValue: value.reminder.uuid)
        let title = LocalizedString.performReminderTitle(for: value.reminder.kind,
                                                      andVesselName: value.reminderVessel.name)
        let description = LocalizedString.performReminderDescription
        let phrase = LocalizedString.genericLocalizedPhrase
        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: value.reminderVessel.imageData)
    }

    private func updateEditReminder(activity: NSUserActivity, value: ReminderAndVesselValue) {
        assert(activity.activityType == RawUserActivity.editReminder.rawValue)

        let uuid = Reminder.Identifier(rawValue: value.reminder.uuid)
        let title = LocalizedString.editReminderTitle(for: value.reminder.kind,
                                                      andVesselName: value.reminderVessel.name)
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.editReminderDescription

        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: value.reminderVessel.imageData)
    }
}

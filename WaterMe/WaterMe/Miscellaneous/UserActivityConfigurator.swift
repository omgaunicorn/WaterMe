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
    var currentReminderAndVessels: (() -> [ReminderAndVesselValue])? { get set }
    var currentReminderVessel: (() -> ReminderVesselValue?)? { get set }
    var requiresMainThreadExecution: Bool { get set }
}

class UserActivityConfigurator: NSObject, UserActivityConfiguratorProtocol {
    var currentReminderAndVessels: (() -> [ReminderAndVesselValue])?
    var currentReminderVessel: (() -> ReminderVesselValue?)?
    var requiresMainThreadExecution = true
}

extension UserActivityConfigurator: NSUserActivityDelegate {
    func userActivityWillSave(_ activity: NSUserActivity) {
        let workItem = {
            guard let kind = RawUserActivity(rawValue: activity.activityType) else {
                assertionFailure("Unsupported User Activity Type")
                return
            }

            let reminderVessel = self.currentReminderVessel?()
            let values = self.currentReminderAndVessels?()
            
            switch kind {
            case .editReminderVessel:
                self.updateEditReminderVessel(activity: activity,
                                              reminderVessel: reminderVessel)
            case .editReminder:
                self.updateEditReminder(activity: activity, value: values?.first)
            case .viewReminder:
                self.updateViewReminder(activity: activity, value: values?.first)
            case .performReminders:
                self.updatePerformMultipleReminders(activity: activity,
                                                    reminders: values ?? [])
            case .indexedItem:
                assertionFailure("Cannot update the data on a CoreSpotlight activity")
            }
        }
        // check if we're NOT on the main thread
        // if we are just, execute the workitem
        guard DispatchQueue.isMain == false else {
            workItem()
            return
        }
        // check if the user of this class needs
        // the execution to happen on the main thread
        // if they don't, just execute the work item
        guard self.requiresMainThreadExecution else {
            workItem()
            return
        }
        // now hop on the main thread and execute
        DispatchQueue.main.sync() {
            workItem()
            return
        }
    }
}

private extension UserActivityConfigurator {

    private func updateEditReminderVessel(activity: NSUserActivity, reminderVessel: ReminderVesselValue?) {
        assert(activity.activityType == RawUserActivity.editReminderVessel.rawValue)
        guard let reminderVessel = reminderVessel else {
            assertionFailure("Missing Reminder Vessel")
            return
        }

        let uuid = reminderVessel.uuid
        let title = LocalizedString.editVesselTitle(fromVesselName: reminderVessel.name)
        let phrase = LocalizedString.genericLocalizedPhrase
        let description = LocalizedString.editReminderVesselDescription

        activity.update(uuids: [uuid],
                        title: title,
                        phrase: phrase,
                        description: description,
                        thumbnailData: reminderVessel.imageData)
    }

    private func updateViewReminder(activity: NSUserActivity, value: ReminderAndVesselValue?) {
        assert(activity.activityType == RawUserActivity.viewReminder.rawValue)
        guard let value = value else {
            assertionFailure("Missing Reminder")
            return
        }

        let uuid = value.reminder.uuid
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
                                                reminders: [ReminderAndVesselValue])
    {
        assert(activity.activityType == RawUserActivity.performReminders.rawValue)
        guard reminders.isEmpty == false else {
            assertionFailure("Missing Reminder")
            return
        }

        if let value = reminders.first, reminders.count == 1 {
            let uuid = value.reminder.uuid
            let title = LocalizedString.performReminderTitle(for: value.reminder.kind,
                                                             andVesselName: value.reminderVessel.name)
            let description = LocalizedString.performReminderDescription
            let phrase = LocalizedString.genericLocalizedPhrase
            activity.update(uuids: [uuid],
                            title: title,
                            phrase: phrase,
                            description: description,
                            thumbnailData: value.reminderVessel.imageData)
        } else {
            let uuids = reminders.map({ $0.reminder.uuid })
            let title = LocalizedString.performMultipleRemindersTitle
            let description = LocalizedString.performMultipleRemindersDescription
            let phrase = LocalizedString.genericLocalizedPhrase
            activity.update(uuids: uuids,
                            title: title,
                            phrase: phrase,
                            description: description,
                            thumbnailData: nil)
        }
    }

    private func updateEditReminder(activity: NSUserActivity,
                                    value: ReminderAndVesselValue?)
    {
        assert(activity.activityType == RawUserActivity.editReminder.rawValue)
        guard let value = value else {
            assertionFailure("Missing Reminder")
            return
        }

        let uuid = value.reminder.uuid
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

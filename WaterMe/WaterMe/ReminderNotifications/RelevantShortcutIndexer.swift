//
//  RelevantShortcutIndexer.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/14/18.
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

import Intents

protocol RelevantShortcutIndexerProtocol {
    static func updateShortcutIndex(with values: [ReminderAndVesselValue])
}

@available(iOS 12.0, *)
class RelevantShortcutIndexer: RelevantShortcutIndexerProtocol {

    private static let taskName = String(describing: RelevantShortcutIndexer.self) + "_SerialQueue_" + UUID().uuidString
    private static let queue = DispatchQueue(label: taskName, qos: .utility)
    private static var backgroundTaskID: UIBackgroundTaskIdentifier?

    class func updateShortcutIndex(with values: [ReminderAndVesselValue]) {
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            log.info("Background task already in progress. Bailing.")
            return
        }
        self.queue.async {
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: self.taskName,
                                                                             expirationHandler: nil)
            self.raw_updateShortcutIndex(with: values)
            DispatchQueue.main.async {
                guard let id = self.backgroundTaskID else { return }
                self.backgroundTaskID = nil
                UIApplication.shared.endBackgroundTask(id)
            }
        }
    }

    private static var delegates = [ReminderAndVesselValue : UserActivityConfiguratorProtocol]()
    
    private class func raw_updateShortcutIndex(with values: [ReminderAndVesselValue]) {

        values.forEach() { value in
            let delegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()
            delegate.requiresMainThreadExecution = false
            delegate.currentReminderAndVessel = { return value }
            delegate.currentReminderVessel = { return value.reminderVessel }
            self.delegates[value] = delegate
        }

        let viewReminderShortcuts = values.compactMap() { value -> INRelevantShortcut? in
            guard let delegate = self.delegates[value] else { return nil }
            let shortcut = INRelevantShortcut(kind: .viewReminder, value: value, delegate: delegate)
            shortcut.shortcutRole = .information
            return shortcut
        }
        let editReminderShortcuts = values.compactMap() { value -> INRelevantShortcut? in
            guard let delegate = self.delegates[value] else { return nil }
            let shortcut = INRelevantShortcut(kind: .editReminder, value: value, delegate: delegate)
            shortcut.shortcutRole = .information
            return shortcut
        }
        let editReminderVesselShortcuts = values.compactMap() { value -> INRelevantShortcut? in
            guard let delegate = self.delegates[value] else { return nil }
            let shortcut = INRelevantShortcut(kind: .editReminderVessel, value: value, delegate: delegate)
            shortcut.shortcutRole = .information
            return shortcut
        }
        let performReminderShortcuts = values.compactMap() { value -> INRelevantShortcut? in
            guard let delegate = self.delegates[value] else { return nil }
            let shortcut = INRelevantShortcut(kind: .performReminders, value: value, delegate: delegate)
            shortcut.shortcutRole = .action
            return shortcut
        }

        assert({
            let valuesCount = values.count
            return viewReminderShortcuts.count == valuesCount
                && editReminderShortcuts.count == valuesCount
                && editReminderVesselShortcuts.count == valuesCount
                && performReminderShortcuts.count == valuesCount

        }())
        let allShortcuts = viewReminderShortcuts
                + editReminderShortcuts
                + editReminderVesselShortcuts
                + performReminderShortcuts
        
        try? INRelevantShortcutStore.default.sync_setRelevantShortcuts(allShortcuts)
        self.delegates = [:]
        log.debug("Relevent Shortcut Items Indexed: \(allShortcuts.count)")
    }
}

@available(iOS 12.0, *)
extension INRelevantShortcut {

    fileprivate convenience init(kind: RawUserActivity,
                                 value: ReminderAndVesselValue,
                                 delegate: UserActivityConfiguratorProtocol)
    {
        let activity = NSUserActivity(kind: kind, delegate: delegate)
        activity.needsSave = true
        let shortcut = INShortcut(userActivity: activity)
        self.init(shortcut: shortcut)
    }
}

@available(iOS 12.0, *)
extension INRelevantShortcutStore {

    fileprivate func sync_setRelevantShortcuts(_ shortcuts: [INRelevantShortcut]) throws {
        var _error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        self.setRelevantShortcuts(shortcuts) { __error in
            _error = __error
            semaphore.signal()
        }
        semaphore.wait()
        guard let error = _error else { return }
        throw error
    }
}

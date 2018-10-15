//
//  GlobalReminderObserver.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 7/2/18.
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
import RealmSwift
import UserNotifications

class GlobalReminderObserver {

    private enum DataKind {
        case badge, notifications, systemIndexes, all
    }

    private let spotlightIndexer = CoreSpotlightIndexer.self
    private let shortcutSuggester: ShortcutSuggesterProtocol.Type? = {
        guard #available(iOS 12.0, *) else { return nil }
        return ShortcutSuggester.self
    }()
    private let badgeNumberController = BadgeNumberController.self
    private let notificationController = ReminderUserNotificationController()
    private let significantTimePassedDetector = SignificantTimePassedDetector()
    private let basicRC: BasicController

    private var data: AnyRealmCollection<Reminder>?
    private var timer: Timer?

    private let taskName = String(describing: GlobalReminderObserver.self) + UUID().uuidString
    private var backgroundTaskID: UIBackgroundTaskIdentifier?

    init(basicController: BasicController) {
        self.basicRC = basicController
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.applicationDidEnterBackground(with:)),
                                               name: .UIApplicationDidEnterBackground,
                                               object: nil)
        self.significantTimePassedDetector.delegate = self
        
        DispatchQueue.main.async {
            let collection = basicController.allReminders(sorted: .nextPerformDate, ascending: true).value
            self.token = collection?.observe({ [weak self] in self?.dataChanged($0) })
        }
    }

    func notificationPermissionsMayHaveChanged() {
        self.resetTimer()
    }

    private func dataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.data = data
            self.dataChanged(of: .all)
        case .update:
            self.resetTimer()
        case .error(let error):
            self.data = nil
            self.token?.invalidate()
            self.token = nil
            Analytics.log(error: error)
            log.error(error)
        }
    }

    private func dataChanged(of kind: DataKind) {
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            log.info("Background task already in progress. Bailing.")
            return
        }
        // start a background task
        self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: self.taskName,
                                                                         expirationHandler: nil)
        let data = Array(self.data?.compactMap({ ReminderAndVesselValue(reminder: $0) }) ?? [])
        switch kind {
        case .notifications:
            self.notificationController.perform(with: data)
        case .badge:
            self.badgeNumberController.perform(with: data)
        case .systemIndexes:
            self.spotlightIndexer.perform(with: data)
            self.shortcutSuggester?.perform(with: data)
        case .all:
            self.notificationController.perform(with: data)
            self.spotlightIndexer.perform(with: data)
            self.shortcutSuggester?.perform(with: data)
            self.badgeNumberController.perform(with: data)
        }
        // end the background task
        guard let id = self.backgroundTaskID else { return }
        self.backgroundTaskID = nil
        UIApplication.shared.endBackgroundTask(id)
    }

    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
            timer.invalidate()
            self.timer?.invalidate()
            self.timer = nil
            self.dataChanged(of: .all)
        }
    }

    @objc private func applicationDidEnterBackground(with notification: Notification?) {
        self.timer?.fire()
    }

    private var token: NotificationToken?

    deinit {
        self.token?.invalidate()
    }
}

extension GlobalReminderObserver: SignificantTimePassedDetectorDelegate {
    // when the data is stale because of significant time passing, we need to refresh the app icon
    func significantTimeDidPass(with _: SignificantTimePassedDetector.Reason,
                                detector _: SignificantTimePassedDetector)
    {
        self.dataChanged(of: .badge)
    }
}

struct ReminderAndVesselValue: Hashable {
    var reminder: ReminderValue2
    var reminderVessel: ReminderVesselValue

    init?(reminder: Reminder?) {
        guard let reminder = reminder else { return nil }
        let _vessel = ReminderVesselValue(reminderVessel: reminder.vessel)
        guard let vessel = _vessel else { return nil }
        self.reminderVessel = vessel
        self.reminder = ReminderValue2(reminder: reminder)
    }

    static func uniqueParentPlantNames(from values: [ReminderAndVesselValue]) -> [String?] {
        let uniqueParents = Dictionary(grouping: values, by: { $0.reminderVessel.uuid })
        let parentNames = uniqueParents.map({ $0.value.first?.reminderVessel.name })
        return parentNames
    }
}

struct ReminderValue2: Hashable {
    var uuid: String
    var nextPerformDate: Date?
    var kind: Reminder.Kind

    init(reminder: Reminder) {
        self.uuid = reminder.uuid
        self.nextPerformDate = reminder.nextPerformDate
        self.kind = reminder.kind
    }
}

struct ReminderVesselValue: Hashable {
    var uuid: String
    var name: String?
    var imageData: Data?

    init?(reminderVessel: ReminderVessel?) {
        guard let reminderVessel = reminderVessel else { return nil }
        self.uuid = reminderVessel.uuid
        self.name = reminderVessel.shortLabelSafeDisplayName
        self.imageData = reminderVessel.iconImageData
    }
}

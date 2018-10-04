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
        case badge, notifications, spotlightIndex, all
    }

    private let spotlightIndexer = CoreSpotlightIndexer.self
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
        let data = Array(self.data?.map({ ReminderValue(reminder: $0) }) ?? [])
        switch kind {
        case .notifications:
            self.notificationController.updateScheduledNotifications(with: data)
        case .badge:
            self.badgeNumberController.updateBadgeNumber(with: data)
        case .all:
            self.notificationController.updateScheduledNotifications(with: data)
            self.badgeNumberController.updateBadgeNumber(with: data)
            fallthrough
        case .spotlightIndex:
            let _vessels = self.basicRC.allVessels().value
            let vessels = Array(_vessels?.map({ ReminderVesselValue(reminderVessel: $0) }) ?? [])
            self.spotlightIndexer.updateSpotlightIndex(reminders: data, reminderVessels: vessels)
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

struct ReminderValue {
    var parentPlantUUID: String
    var parentPlantName: String?
    var parentPlantImageData: Data?
    var nextPerformDate: Date?
    var reminderKind: Reminder.Kind
    var reminderUUID: String

    init(reminder: Reminder) {
        self.parentPlantImageData = reminder.vessel?.iconImageData
        self.reminderUUID = reminder.uuid
        self.reminderKind = reminder.kind
        self.parentPlantUUID = reminder.vessel?.uuid ?? UUID().uuidString
        self.parentPlantName = reminder.vessel?.shortLabelSafeDisplayName
        self.nextPerformDate = reminder.nextPerformDate
    }

    static func uniqueParentPlantNames(from reminders: [ReminderValue]) -> [String?] {
        let uniqueParents = Dictionary(grouping: reminders, by: { $0.parentPlantUUID })
        let parentNames = uniqueParents.map({ $0.value.first?.parentPlantName })
        return parentNames
    }
}

struct ReminderVesselValue {
    var uuid: String
    var name: String?
    var imageData: Data?

    init(reminderVessel: ReminderVessel) {
        self.uuid = reminderVessel.uuid
        self.name = reminderVessel.shortLabelSafeDisplayName
        self.imageData = reminderVessel.iconImageData
    }
}

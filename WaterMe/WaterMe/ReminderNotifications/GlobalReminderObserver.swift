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

class GlobalReminderObserver {

    private let badgeNumberController = BadgeNumberController.self
    private let notificationController = ReminderUserNotificationController()

    private var data: AnyRealmCollection<Reminder>?
    private var timer: Timer?

    init?(basicController: BasicController?) {
        guard
            let basicController = basicController,
            let collection = basicController.allReminders().value
        else {
            let message = "Error Initializing: Error loading data from Realm."
            log.error(message)
            assertionFailure(message)
            return nil
        }

        self.token = collection.observe({ [weak self] in self?.dataChanged($0) })
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground(with:)), name: .UIApplicationDidEnterBackground, object: nil)
    }

    func notificationPermissionsMayHaveChanged() {
        self.resetTimer()
    }

    private func dataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.data = data
            self.dataChanged()
        case .update:
            self.resetTimer()
        case .error(let error):
            self.data = nil
            self.token?.invalidate()
            self.token = nil
            self.dataChanged()
            log.error("Realm Error: \(error)")
        }
    }

    private func dataChanged() {
        let data = Array(self.data?.map({ ReminderValue(reminder: $0) }) ?? [])
        self.notificationController.updateScheduledNotifications(with: data)
        self.badgeNumberController.updateBadgeNumber(with: data)
    }

    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
            timer.invalidate()
            self.timer?.invalidate()
            self.timer = nil
            self.dataChanged()
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

struct ReminderValue {
    var parentPlantUUID: String
    var parentPlantName: String?
    var nextPerformDate: Date?

    init(reminder: Reminder) {
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

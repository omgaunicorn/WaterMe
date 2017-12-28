//
//  ReminderUserNotificationController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 03/11/17.
//  Copyright © 2017 Saturday Apps.
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

class ReminderUserNotificationController {

    private var data: AnyRealmCollection<Reminder>?

    private let queue = DispatchQueue(label: String(describing: ReminderUserNotificationController.self) + "_SerialQueue", qos: .utility)

    private var timer: Timer?

    init?(basicController: BasicController) {
        guard let collection = basicController.allReminders().value else { return nil }
        self.token = collection.observe({ [weak self] in self?.dataChanged($0) })
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground(with:)), name: .UIApplicationDidEnterBackground, object: nil)
    }

    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { timer in
            timer.invalidate()
            self.timer?.invalidate()
            self.timer = nil
            self.updateScheduledNotifications()
        }
    }

    private func dataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.data = data
            self.resetTimer()
        case .update:
            self.resetTimer()
        case .error(let error):
            self.data = nil
            self.token?.invalidate()
            self.token = nil
            self.updateScheduledNotifications()
            log.error("Realm Error in 'ReminderUserNotificationController': \(error)")
        }
    }

    @objc private func applicationDidEnterBackground(with notification: Notification?) {
        self.resetTimer()
        self.timer!.fire()
    }

    private func updateScheduledNotifications() {
        // DispatchQueue(label: String(describing: type(of: self)), qos: .utility).async { [weak self] in
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        guard let data = self.data, data.isEmpty == false else {
            log.error("Reminder data for notifications was NIL or was empty: \(String(describing: self.data?.isEmpty))")
            return
        }
        center.authorized() { authorized in
            guard authorized else {
                log.info("Not authorized to schedule notifications")
                return
            }
            self.notificationRequests() { requests in
                guard requests.isEmpty == false else {
                    log.debug("No notifications to schedule")
                    return
                }
                for request in requests {
                    center.add(request) { error in
                        guard let error = error else { return }
                        log.error(error)
                    }
                }
                log.debug("Scheduled Notifications: \(requests.count)")
            }
        }
    }

    private func notificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        // make sure we have data to work with
        guard let _data = self.data, _data.isEmpty == false else { completion([]); return; }

        // get preference values for reminder time and number of days to remind for
        let reminderHour = UserDefaults.standard.reminderHour
        let reminderDays = UserDefaults.standard.reminderDays

        // get some constants we'll use throughout
        let calendar = Calendar.current
        let nowReminderTime = calendar.dateWithExact(hour: reminderHour, onSameDayAs: Date())

        // get immutable versions of the data
        let data = Array(_data.map({ ReminderNotificationInformation(reminder: $0) }))

        // hop on a background queue to do the processing
        self.queue.async {
            // loop through the number of days the user wants to be reminded for
            // get all reminders that happened on or before the end of the day of `futureReminderTime`
            let matches = (0 ..< reminderDays).flatMap() { i -> (Date, [ReminderNotificationInformation])? in
                let futureReminderTime = nowReminderTime + TimeInterval(i * 24 * 60 * 60)
                let endOfFutureDay = calendar.endOfDay(for: futureReminderTime)
                let matches = data.filter() { reminder -> Bool in
                    let reminderTime = calendar.dateWithExact(hour: reminderHour, onSameDayAs: reminder.nextPerformDate)
                    return (reminderTime ?? nowReminderTime) <= endOfFutureDay
                }
                guard matches.isEmpty == false else { return nil }
                return (futureReminderTime, matches)
            }

            // convert the matches into one notification each
            // this makes it so the user only gets 1 notification per day at the time they requested
            let reminders = matches.map() { reminderTime, matches -> UNNotificationRequest in
                let interval = reminderTime.timeIntervalSince(nowReminderTime)
                let trigger: UNTimeIntervalNotificationTrigger?
                if interval <= 0 {
                    // if trigger is less than or equal to 0 we need to tell the system there is no trigger
                    // this causes it to send the notification immediately
                    trigger = nil
                } else {
                    trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                }
                let _content = UNMutableNotificationContent()
                // shuffle the names so that different plant names show in the notifications
                let plantNames = ReminderNotificationInformation.uniqueParentPlantNames(from: matches).shuffled()
                _content.body = ReminderUserNotificationController.LocalizedStrings.notificationBodyWithPlantNames(plantNames: plantNames)
                // swiftlint:disable:next force_cast
                let content = _content.copy() as! UNNotificationContent // if this crashes something really bad is happening
                let request = UNNotificationRequest(identifier: reminderTime.description, content: content, trigger: trigger)
                return request
            }

            // call the completion handler
            completion(reminders)
        }
    }

    private var token: NotificationToken?

    deinit {
        self.token?.invalidate()
    }
}

private struct ReminderNotificationInformation {
    var parentPlantUUID: String
    var parentPlantName: String?
    var nextPerformDate: Date?

    init(reminder: Reminder) {
        self.parentPlantUUID = reminder.vessel!.uuid
        self.parentPlantName = reminder.vessel!.displayName
        self.nextPerformDate = reminder.nextPerformDate
    }

    static func uniqueParentPlantNames(from reminders: [ReminderNotificationInformation]) -> [String?] {
        let uniqueParents = Dictionary(grouping: reminders, by: { $0.parentPlantUUID })
        let parentNames = uniqueParents.map({ $0.value.first?.parentPlantName })
        return parentNames
    }
}

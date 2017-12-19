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

    init?(basicController: BasicController) {
        guard let collection = basicController.allReminders().value else { return nil }
        self.token = collection.observe({ [weak self] in self?.dataChanged($0) })
    }

    private func dataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.data = data
            self.updateScheduledNotifications()
        case .update:
            self.updateScheduledNotifications()
        case .error(let error):
            self.data = nil
            self.token?.invalidate()
            self.token = nil
            self.updateScheduledNotifications()
            log.error("Realm Error in 'ReminderUserNotificationController': \(error)")
        }
    }

    private func updateScheduledNotifications() {
        // DispatchQueue(label: String(describing: type(of: self)), qos: .utility).async { [weak self] in
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        guard let data = self.data else {
            log.error("Reminder data for notifications was NIL")
            return
        }
        center.authorized() { authorized in
            guard authorized else {
                log.info("Not authorized to schedule notifications")
                return
            }
            let requests = self.notificationRequests(from: data)
            guard requests.isEmpty == false else {
                log.debug("No notifications to schedule")
                return
            }
            for request in requests {
                center.add(request) { error in
                    print(error)
                }
            }
        }
    }

    private func notificationRequests(from reminders: AnyRealmCollection<Reminder>) -> [UNNotificationRequest] {
        // make sure we have data to work with
        guard let _data = self.data, _data.isEmpty == false else { return [] }

        // get preference values for reminder time and number of days to remind for
        let reminderHour = UserDefaults.standard.reminderHour
        let reminderDays = UserDefaults.standard.reminderDays

        // get some constants we'll use throughout
        let calendar = Calendar.current
        let nowReminderTime = calendar.dateWithExact(hour: reminderHour, onSameDayAs: Date())

        // get immutable versions of the dats
        // need to fix this so we get Struct copies from the realm objects
        let data = Array(_data)

        // loop through the number of days the user wants to be reminded for
        // get all reminders that happened on or before the end of the day of `futureReminderTime`
        let matches = (0 ..< reminderDays).flatMap() { i -> (Date, [Reminder])? in
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
        let reminders = matches.map() { reminderTime, matches -> UNNotificationRequest in
            let _interval = reminderTime.timeIntervalSince(nowReminderTime)
            let interval = _interval < UNTimeIntervalNotificationTrigger.kMin ? UNTimeIntervalNotificationTrigger.kMin : _interval
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let _content = UNMutableNotificationContent()
            print("\(reminderTime): Reminders: \(matches.count)")
            _content.body = "Reminders: \(matches.count)"
            // swiftlint:disable:next force_cast
            let content = _content.copy() as! UNNotificationContent // if this crashes something really bad is happening
            let request = UNNotificationRequest(identifier: reminderTime.description, content: content, trigger: trigger)
            return request
        }
        return reminders
    }

    private var token: NotificationToken?

    deinit {
        self.token?.invalidate()
    }
}

extension UNTimeIntervalNotificationTrigger {
    static let kMin: TimeInterval = 1.675
}

extension UNUserNotificationCenter {
    func authorized(completion: @escaping (Bool) -> Void) {
        self.getNotificationSettings() { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus.boolValue)
            }
        }
    }
}

extension UNAuthorizationStatus {
    var boolValue: Bool {
        switch self {
        case .authorized:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}

extension ReminderUserNotificationController {
    enum LocalizedStrings {
        static func notificationBody(withVesselName vesselName: String?, reminderKind: Reminder.Kind) -> String {
            let vesselName = vesselName ?? "Untitled Plant"
            switch reminderKind {
            case .water:
                return "\(vesselName) needs to be watered."
            case .fertilize:
                return "\(vesselName) needs to be fertilized."
            case .move(location: let location):
                if let location = location {
                    return "\(vesselName) needs to be moved to: '\(location).'"
                } else {
                    return "\(vesselName) needs to be moved."
                }
            case .other(description: let description):
                if let description = description {
                    return "\(vesselName): '\(description)'"
                } else {
                    return "\(vesselName): Unknown Reminder"
                }
            }
        }
    }
}

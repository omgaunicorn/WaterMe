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
        // self.resetAllNotifications
        guard let data = self.data else {
            log.error("Reminder data for notifications was NIL")
            return
        }
        let center = UNUserNotificationCenter.current()
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
        let map = reminders.map() { reminder -> UNNotificationRequest in
            let calendar = Calendar.current
            let _date = reminder.nextPerformDate ?? Date()
            let date = calendar.dateWithExact(hour: 8, on: _date)
            let components = Calendar.current.dateComponents([.hour, .day, .month, .year, .era], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let _content = UNMutableNotificationContent()
            _content.body = "Something needs to be done!"
            // swiftlint:disable:next force_cast
            let content = _content.copy() as! UNNotificationContent // if this crashes something really bad is happening
            let request = UNNotificationRequest(identifier: reminder.uuid, content: content, trigger: trigger)
            return request
        }
        return Array(map)
    }

    private var token: NotificationToken?

    deinit {
        self.token?.invalidate()
    }
}

extension UNUserNotificationCenter {
    func authorized(completion: @escaping (Bool) -> Void) {
        self.getNotificationSettings() { settings in
            let authorized: Bool
            switch settings.authorizationStatus {
            case .authorized:
                authorized = true
            case .denied, .notDetermined:
                authorized = false
            }
            DispatchQueue.main.async {
                completion(authorized)
            }
        }
    }
}

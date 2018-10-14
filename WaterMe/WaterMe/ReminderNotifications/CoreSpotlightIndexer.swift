//
//  CoreSpotlightIndexer.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/3/18.
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
import CoreSpotlight
import MobileCoreServices

class CoreSpotlightIndexer {

    private static let taskName = String(describing: CoreSpotlightIndexer.self) + "_SerialQueue_" + UUID().uuidString
    private static let queue = DispatchQueue(label: taskName, qos: .utility)
    private static var backgroundTaskID: UIBackgroundTaskIdentifier?

    class func updateSpotlightIndex(with values: [ReminderAndVesselValue]) {
        // make sure there isn't already a background task in progress
        guard self.backgroundTaskID == nil else {
            Analytics.log(event: Analytics.NotificationPermission.scheduleAlreadyInProgress)
            log.info("Background task already in progress. Bailing.")
            return
        }
        self.queue.async {
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: self.taskName,
                                                                             expirationHandler: nil)
            let index = CSSearchableIndex.default()
            let deleteError = index.sync_deleteAllSearchableItems()
            if let error = deleteError {
                log.error(error)
                Analytics.log(error: error)
                assertionFailure(String(describing: error))
                return
            }
            let reminderItems = CSSearchableItem.items(from: values)
            let reminderIndexError = index.sync_indexSearchableItems(items: reminderItems)
            if let error = reminderIndexError {
                log.error(error)
                Analytics.log(error: error)
                assertionFailure(String(describing: error))
                return
            }
            DispatchQueue.main.async {
                log.debug("Spotlight Items Indexed: \(reminderItems.count)")
                guard let id = self.backgroundTaskID else { return }
                self.backgroundTaskID = nil
                UIApplication.shared.endBackgroundTask(id)
            }
        }
    }
}

extension CSSearchableIndex {
    func sync_deleteAllSearchableItems() -> Error? {
        var _error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        self.deleteAllSearchableItems() { error in
            _error = error
            semaphore.signal()
        }
        semaphore.wait()
        return _error
    }
    func sync_indexSearchableItems(items: [CSSearchableItem]) -> Error? {
        var _error: Error?
        let semaphore = DispatchSemaphore(value: 0)
        self.indexSearchableItems(items) { error in
            _error = error
            semaphore.signal()
        }
        semaphore.wait()
        return _error
    }

}

extension CSSearchableItem {
    class func items(from values: [ReminderAndVesselValue]) -> [CSSearchableItem] {
        return values.map() { value -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
            attributes.title = UserActivityConfigurator.LocalizedString.title(for: value.reminder.kind,
                                                                              andVesselName: value.reminderVessel.name)
            attributes.contentDescription = CoreSpotlightIndexer.LocalizedString.description
            attributes.thumbnailData = value.reminderVessel.imageData
            let uuid = NSUserActivity.uniqueString(for: RawUserActivity.viewReminder,
                                                   and: [Reminder.Identifier(rawValue: value.reminder.uuid)])
            let item = CSSearchableItem(uniqueIdentifier: uuid,
                                        domainIdentifier: RawUserActivity.viewReminder.rawValue,
                                        attributeSet: attributes)
            return item
        }
    }
}

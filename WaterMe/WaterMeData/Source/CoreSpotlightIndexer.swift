//
//  CoreSpotlightIndexer.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/2/18.
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

import RealmSwift
import CoreSpotlight
import MobileCoreServices

public class CoreSpotlightIndexer: HasBasicController {

    private let queue: DispatchQueue = {
        let name = "com.saturdayapps.waterme.csindexer.queue.\(UUID().uuidString)"
        let q = DispatchQueue(label: name, qos: .background)
        return q
    }()

    private var reminderVessels: AnyRealmCollection<ReminderVessel>?

    public var basicRC: BasicController? {
        didSet { self.hardReloadData() }
    }

    private var reminderVesselsToken: NotificationToken?

    public init() { }

    private func hardReloadData() {
        self.reminderVesselsToken?.invalidate()
        self.reminderVesselsToken = nil
        guard let basicRC = self.basicRC else { return }
        self.reminderVessels = basicRC.allVessels().value
        self.reminderVesselsToken = self.reminderVessels?.observe() { [weak self] c in
            self?.reminderVesselsChanged(c)
        }
    }

    private func reminderVesselsChanged(_ changes: RealmCollectionChange<AnyRealmCollection<ReminderVessel>>) {
        switch changes {
        case .initial(let data), .update(let data, _, _, _):
            self.replaceIndexWithReminderVessels(data)
        case .error(let error):
            log.error(error)
            assertionFailure(String(describing: error))
        }
    }

    private func replaceIndexWithReminderVessels(_ vessels: AnyRealmCollection<ReminderVessel>) {
        let _items = vessels.map() { vessel -> CSSearchableItem in
            let vas = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
            vas.title = vessel.displayName ?? "My Plant"
            vas.contentDescription = "Edit plant name, photo, reminders."
            vas.thumbnailData = vessel.iconImageData
            let vi = CSSearchableItem(uniqueIdentifier: vessel.uuid,
                                      domainIdentifier: RawUserActivity.editReminderVessel.rawValue,
                                      attributeSet: vas)
            return vi
        }
        let items = Array(_items)
        self.queue.async {
            let index = CSSearchableIndex.default()
            let semaphore = DispatchSemaphore(value: 0)
            index.deleteAllSearchableItems() { error in
                if let error = error {
                    log.error(error)
                    assertionFailure(String(describing: error))
                    return
                }
                semaphore.signal()
            }
            semaphore.wait()
            log.info("Requesting Indexing: \(items.count) items.")
            index.indexSearchableItems(items) { error in
                log.info("Finished Indexing: \(items.count) items.")
                guard let error = error else { return }
                log.error(error)
                assertionFailure(String(describing: error))
            }
        }
    }
}

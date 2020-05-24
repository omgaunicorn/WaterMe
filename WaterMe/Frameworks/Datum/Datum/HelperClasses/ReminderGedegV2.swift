//
//  ReminderGedeg.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 19/10/17.
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

import Foundation

/**
 Contains a bunch of functions that take a collection of Reminders and produce indexpaths and vice versa
 IndexPaths represent reminders grouped by when they need to be performed next
 i.e. Today, Tomorrow, This Week, Later
 Gedeg == Grouper / Degrouper
 */

internal class ReminderGedegV2<Query: CollectionQuery, Section: Hashable & RawRepresentable>
    : NSObject, ObservationToken
    where Query.Index == Int, Section.RawValue == Int
{
    
    internal typealias InputChange = CollectionChange<Query.Collection, Query.Index>
    internal typealias OutputChange = CollectionChange<ReminderGedegV2, IndexPath>
    
    private var data: [Section : Query.Collection] = [:]
    private let queries: [Section : Query]
    private let updateBatcher = Batcher()
    
    private var currentObserver: (closure: ((OutputChange) -> Void)?, tokens: [ObservationToken])?

    internal var allSectionsFinishedLoading: Bool {
        return self.data.count == self.queries.count
    }

    internal init?(queries: [Section : Query]) {
        self.queries = queries
        super.init()
    }
    
    internal func observe(_ block: @escaping (OutputChange) -> Void) -> ObservationToken {
        guard self.currentObserver == nil else { return self }
        self.updateBatcher.batchFired = block
        var tokens = [ObservationToken]()
        for (section, query) in self.queries {
            let t = query.observe { [weak self] change in
                guard let self = self else { return }
                switch change {
                case .initial(let data):
                    self.data[section] = data
                    if self.allSectionsFinishedLoading {
                        block(.initial(data: self))
                    }
                case .update(let change):
                    self.updateBatcher.append(change: change, for: section)
                case .error:
                    self.invalidate()
                    block(.error(error: .readError))
                }
            }
            tokens.append(t)
        }
        self.currentObserver = (block, tokens)
        return self
    }

    internal var numberOfSections: Int {
        // if we haven't finished loading data, always return 0
        guard self.allSectionsFinishedLoading == true else {
            return 0
        }
        return self.data.count
    }

    internal func numberOfItems(inSection _section: Int) -> Int {
        guard
            let section = Section(rawValue: _section),
            let collection = self.data[section]
        else {
            let error = NSError(dataForSectionWasNilInNumberOfItemsInSection: _section)
            assertionFailure(error.localizedDescription)
            log.error(error)
            return 0
        }
        return collection.count
    }

    internal func reminder(at indexPath: IndexPath) -> Query.Collection.Element? {
        guard
            let section = Section(rawValue: indexPath.section),
            let collection = self.data[section]
        else {
            let error = NSError(dataForSectionWasNilInReminderAtIndexPath: indexPath)
            assertionFailure(String(describing: error))
            log.error(error)
            return nil
        }
        
        // swiftlint:disable:next todo
        // FIXME: Crasher Workaround - http://crashes.to/s/ba8c0f6c9ad
        // Sometimes this method is called when an index out of bounds.
        // This should not happen, but this check works around it.
        let row = indexPath.row
        guard collection.count > row else {
            let error = NSError(outOfBoundsRowAtIndexPath: indexPath)
            assertionFailure(String(describing: error))
            log.error(error)
            return nil
        }

        return collection[row]
    }

    // TODO: Try to add this back
//    internal func indexPathOfReminder(with identifier: ReminderIdentifier) -> IndexPath? {
//        var indexPath: IndexPath?
//        for (section, collection) in self.reminders {
//            guard let row = collection.index(matching: "uuid = %@", identifier.uuid) else { continue }
//            indexPath = IndexPath(row: row, section: section.rawValue)
//        }
//        return indexPath
//    }

    internal func invalidate() {
        let tokens = self.currentObserver?.tokens
        self.currentObserver = nil
        tokens?.invalidateTokens()
    }

    deinit {
        self.invalidate()
    }

    private class Batcher {
        typealias OutputUpdate = Update<IndexPath>
        typealias InputUpdate = Update<Query.Index>
        private var timer: Timer?
        private var updates = [OutputUpdate]()
        var batchFired: ((OutputChange) -> Void)?
        func append(change: InputUpdate, for section: Section) {
            self.timer?.invalidate()
            let transformed = Transform_Update_IntToIndex(change, section.rawValue)
            self.updates.append(transformed)
            self.timer = Timer.scheduledTimer(timeInterval: 0.001,
                                              target: self,
                                              selector: #selector(self.timerFired(_:)),
                                              userInfo: nil,
                                              repeats: false)
        }
        @objc private func timerFired(_ timer: Timer?) {
            timer?.invalidate()
            self.timer?.invalidate()
            self.timer = nil
            let updates = self.updates
            self.updates = []
            let ins = Set(updates.flatMap { $0.insertions })
            let dels = Set(updates.flatMap { $0.deletions })
            let mods = Set(updates.flatMap { $0.modifications })
            self.batchFired?(.update((insertions: Array(ins),
                                      deletions: Array(dels),
                                      modifications: Array(mods))))
        }
    }
}

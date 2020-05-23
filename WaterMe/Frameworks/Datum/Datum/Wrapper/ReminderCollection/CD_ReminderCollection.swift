//
//  CD_ReminderCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/21.
//  Copyright © 2020 Saturday Apps.
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

import CoreData

internal class CD_ReminderCollection: ReminderCollection {
    private let controller: CD_ReminderQuery.Controller
    private let transform: (CD_Reminder) -> Reminder = { CD_ReminderWrapper($0) }
    init(_ controller: CD_ReminderQuery.Controller) {
        self.controller = controller
    }
    var count: Int { self.controller.fetchedObjects?.count ?? 0 }
    subscript(index: Int) -> Reminder {
        return self.transform(self.controller.object(at: IndexPath(row: index, section: 0)))
    }
    var isInvalidated: Bool { false }
    func compactMap<E>(_ transform: (Reminder) throws -> E?) rethrows -> [E] {
        return try self.controller.fetchedObjects?.compactMap { try transform(self.transform($0)) } ?? []
    }
    func index(matching predicateFormat: String, _ args: Any...) -> Int? {
        // TODO: Fix this
        return nil
    }
}

internal class CD_ReminderQuery: NSObject, ReminderQuery {
    typealias Controller = NSFetchedResultsController<CD_Reminder>
    private var controller: Controller!
    init(_ controller: Controller) {
        self.controller = controller
        super.init()
        self.controller.delegate = self
    }
    func observe(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        DispatchQueue.main.async {
            do {
                try self.controller.performFetch()
                block(.initial(data: CD_ReminderCollection(self.controller)))
            } catch {
                block(.error(error: .readError))
            }
        }
        return self
    }
}

extension CD_ReminderQuery: NSFetchedResultsControllerDelegate { }

extension CD_ReminderQuery: ObservationToken {
    func invalidate() {
        self.controller.delegate = nil
        self.controller = nil
    }
}

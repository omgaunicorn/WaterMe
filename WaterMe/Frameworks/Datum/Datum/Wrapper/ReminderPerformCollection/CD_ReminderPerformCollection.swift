//
//  CD_ReminderPerformCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/23.
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

internal struct CD_ReminderPerformCollection: ReminderPerformCollection {
    
    private let controller: CD_ReminderPerformQuery.Controller
    private let context: LazyContext
    private let transform: (CD_ReminderPerform) -> ReminderPerformWrapper = { CD_ReminderPerformWrapper($0) }
    
    init(_ controller: CD_ReminderPerformQuery.Controller, context: @escaping LazyContext) {
        self.controller = controller
        self.context = context
    }
    
    var count: Int { self.controller.fetchedObjects?.count ?? 0 }
    subscript(index: Int) -> ReminderPerformWrapper {
        let reminderPerform = self.controller.fetchedObjects![index]
        return self.transform(reminderPerform)
    }
    var last: ReminderPerformWrapper? {
        guard let last = self.controller.fetchedObjects?.last else { return nil }
        return CD_ReminderPerformWrapper(last)
    }
}

internal class CD_ReminderPerformQuery: ReminderPerformQuery {
    typealias Controller = NSFetchedResultsController<CD_ReminderPerform>
    private let controller: Controller
    private let context: LazyContext
    private var delegate: UpdatingFetchedResultsControllerDelegate?
    
    init(_ controller: Controller, context: @escaping LazyContext) {
        self.controller = controller
        self.context = context
    }
    
    func observe(_ block: @escaping (ReminderPerformCollectionChange) -> Void) -> ObservationToken {
        self.delegate = .init() { block(.update(Transform_Update_IndexToInt($0))) }
        self.controller.delegate = self.delegate
        DispatchQueue.main.async {
            do {
                try self.controller.performFetch()
                block(.initial(data: CD_ReminderPerformCollection(self.controller, context: self.context)))
            } catch {
                block(.error(error: .readError))
            }
        }
        return self
    }
}

extension CD_ReminderPerformQuery: ObservationToken {
    func invalidate() {
        self.controller.delegate = nil
        self.delegate = nil
    }
}

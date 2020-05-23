//
//  CD_ReminderVesselCollection.swift
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

internal class CD_ReminderVesselCollection: ReminderVesselCollection {
    private let controller: CD_ReminderVesselQuery.Controller
    init(_ controller: CD_ReminderVesselQuery.Controller) {
        self.controller = controller
    }
    var count: Int { self.controller.fetchedObjects?.count ?? 0 }
    subscript(index: Int) -> ReminderVessel {
        return CD_ReminderVesselWrapper(self.controller.object(at: IndexPath(row: index, section: 0)))
    }
}

internal class CD_ReminderVesselQuery: NSObject, ReminderVesselQuery {
    typealias Controller = NSFetchedResultsController<CD_ReminderVessel>
    private var controller: Controller!
    init(_ controller: Controller) {
        self.controller = controller
        super.init()
        self.controller.delegate = self
    }
    func observe(_ block: @escaping (ReminderVesselCollectionChange) -> Void) -> ObservationToken {
        DispatchQueue.main.async {
            do {
                try self.controller.performFetch()
                block(.initial(data: CD_ReminderVesselCollection(self.controller)))
            } catch {
                block(.error(error: .readError))
            }
        }
        return self
    }
}

extension CD_ReminderVesselQuery: NSFetchedResultsControllerDelegate { }

extension CD_ReminderVesselQuery: ObservationToken {
    func invalidate() {
        self.controller.delegate = nil
        self.controller = nil
    }
}

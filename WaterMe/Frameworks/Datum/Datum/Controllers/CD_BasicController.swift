//
//  CD_BasicController.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/16.
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

public class CD_BasicController: BasicController {

    public class func new() -> Result<CD_BasicController, DatumError> {
        var result: Result<CD_BasicController, DatumError> = .failure(.loadError)
        guard let url = Bundle(for: CD_BasicController.self).url(forResource: "WaterMe",
                                                           withExtension: "momd"),
              let mom = NSManagedObjectModel(contentsOf: url)
        else { return result }
        let container = NSPersistentContainer(name: "WaterMe", managedObjectModel: mom)
        let lock = DispatchSemaphore(value: 0)
        container.loadPersistentStores() { _, error in
            defer { lock.signal() }
            guard error == nil else { return }
            let bc = CD_BasicController(container: container)
            result = .success(bc)
        }
        lock.wait()
        return result
    }

    private let container: NSPersistentContainer

    private init(container: NSPersistentContainer) {
        self.container = container
    }

    public func allVessels() -> Result<ReminderVesselQuery, DatumError> {
        fatalError()
    }
}

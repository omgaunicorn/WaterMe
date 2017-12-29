//
//  CoreDataMigrator.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 29/12/17.
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

import CoreData
import Foundation
import WaterMeData

class WaterMePersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CoreDataMigrator.storeDirectory
    }
}

class CoreDataMigrator {

    static let storeDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let sqLiteURL = appSupport.appendingPathComponent("WaterMe", isDirectory: true)
        return sqLiteURL
    }()

    static let storeURL: URL = {
        return CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite")
    }()

    private let container: NSPersistentContainer

    init?() {
        let sqLiteURL = CoreDataMigrator.storeURL
        // if the file doesn't exist then they never had the old version of the app.
        guard FileManager.default.fileExists(atPath: sqLiteURL.path) == true else { return nil }
        let container = WaterMePersistentContainer(name: "WaterMeData")
        container.persistentStoreDescriptions.first?.isReadOnly = true
        container.loadPersistentStores() { description, error  in
            guard error == nil else {
                let error = "Error Loading Core Data Model. This leaves the Migrator in an invalid state: \(error!)"
                log.error(error)
                assertionFailure(error)
                return
            }
            log.debug("Loaded Core Data Stack: Ready for Migration.")
            let stuff = try! container.viewContext.fetch(NSFetchRequest(entityName: String(describing: PlantEntity.self)))
            print(stuff)
        }
        self.container = container
    }

}

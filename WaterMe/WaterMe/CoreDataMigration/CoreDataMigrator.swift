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

protocol CoreDataMigratable {
    var progress: Progress { get }
    func start(with: BasicController, completion: @escaping (Bool) -> Void) -> Progress
    func deleteCoreDataStoreWithoutMigrating()
}

class CoreDataMigrator: CoreDataMigratable {

    static let storeDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let sqLiteURL = appSupport.appendingPathComponent("WaterMe", isDirectory: true)
        return sqLiteURL
    }()

    static let storeURL: URL = {
        return CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite")
    }()

    let progress = Progress()

    private var numberOfPlantsToMigrate: Int {
        return try! self.container.viewContext.count(for: NSFetchRequest(entityName: String(describing: PlantEntity.self)))
    }

    private let container: NSPersistentContainer

    init?() {
        let sqLiteURL = CoreDataMigrator.storeURL
        // if the file doesn't exist then they never had the old version of the app.
        guard FileManager.default.fileExists(atPath: sqLiteURL.path) == true else { return nil }
        self.container = WaterMePersistentContainer(name: "WaterMeData")
        self.container.persistentStoreDescriptions.first?.isReadOnly = true
        self.container.loadPersistentStores() { _, error  in
            guard error == nil else {
                let error = "Error Loading Core Data Model. This leaves the Migrator in an invalid state: \(error!)"
                log.error(error)
                assertionFailure(error)
                return
            }
            let count = self.numberOfPlantsToMigrate
            self.progress.totalUnitCount = Int64(count)
            self.progress.completedUnitCount = 0
        }
        log.debug("Loaded Core Data Stack: Ready for Migration.")
    }

    func start(with basicRC: BasicController, completion: @escaping (Bool) -> Void) -> Progress {
        let count = self.numberOfPlantsToMigrate
        self.progress.totalUnitCount = Int64(count)
        self.progress.completedUnitCount = 0
        self.container.performBackgroundTask() { c in
            let plants = try! c.fetch(NSFetchRequest(entityName: String(describing: PlantEntity.self)))
            var migrated = 0 {
                didSet {
                    self.progress.completedUnitCount = Int64(migrated)
                }
            }
            for thing in plants {
                print("----- BEGIN PLANT -----")
                guard let plant = thing as? PlantEntity else { continue }
                print(plant.cd_00100_nameString!)
                let imageEmoji = plant.cd_00100_imageEmojiTransformable as? ImageEmojiObject
                let vesselName = plant.cd_00100_nameString
                let vesselImage = imageEmoji?.emojiImage
                let vesselEmoji = imageEmoji?.emojiString
                let reminderInterval = plant.cd_00100_wateringIntervalNumber
                let reminderLastPerformDate = plant.cd_00100_lastWateredDate
                let result = basicRC.coreDataMigration(vesselName: vesselName,
                                                        vesselImage: vesselImage,
                                                        vesselEmoji: vesselEmoji,
                                                        reminderInterval: reminderInterval,
                                                        reminderLastPerformDate: reminderLastPerformDate)
                switch result {
                case .failure(let error):
                    let description = "Error while migrating plant nameed: \(vesselName!): \(error)"
                    log.error(description)
                    assertionFailure(description)
                case .success:
                    migrated += 1
                }
                print("----- END PLANT -----")
            }
            completion(migrated == count)
        }
        return self.progress
    }

    func deleteCoreDataStoreWithoutMigrating() {

    }
}

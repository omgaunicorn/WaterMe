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

private class WaterMePersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CoreDataMigrator.storeDirectory
    }
}

protocol CoreDataMigratable {
    var progress: Progress { get }
    func start(with: BasicController, completion: @escaping (Bool) -> Void)
    func deleteCoreDataStoreWithoutMigrating()
}

class CoreDataMigrator: CoreDataMigratable {

    private static let storeDirectoryPostMigration: URL = {
        return CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMe-PostMigration", isDirectory: true)
    }()

    fileprivate static let storeDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let sqLiteURL = appSupport.appendingPathComponent("WaterMe", isDirectory: true)
        return sqLiteURL
    }()

    private static let storeURL: URL = {
        return CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite")
    }()

    private static let storeFilesToMove: [URL] = {
        return [
            CoreDataMigrator.storeURL,
            CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite-shm"),
            CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite-wal")
        ]
    }()

    private class func plants(from c: NSManagedObjectContext) -> [Any] {
        do {
            return try c.fetch(NSFetchRequest(entityName: String(describing: PlantEntity.self)))
        } catch {
            let message = "CoreDataError Fetching old plants: \(error)"
            log.error(message)
            assertionFailure(message)
            return []
        }
    }

    private var numberOfPlantsToMigrate: Int? {
        do {
            return try self.container.viewContext.count(for: NSFetchRequest(entityName: String(describing: PlantEntity.self)))
        } catch {
            let message = "CoreDataError Fetching Count of old plants: \(error)"
            log.error(message)
            assertionFailure(message)
            return nil
        }
    }

    private let container: NSPersistentContainer

    let progress = Progress()

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
            self.progress.totalUnitCount = Int64(count ?? -1)
            self.progress.completedUnitCount = 0
        }
        log.debug("Loaded Core Data Stack: Ready for Migration.")
    }

    func start(with basicRC: BasicController, completion: @escaping (Bool) -> Void) {
        let count = self.numberOfPlantsToMigrate ?? -1
        self.progress.totalUnitCount = Int64(count)
        self.progress.completedUnitCount = 0
        self.container.performBackgroundTask() { c in
            var migrated = 0 {
                didSet {
                    self.progress.completedUnitCount = Int64(migrated)
                }
            }
            let plants = type(of: self).plants(from: c)
            plants.forEach() { _plant in
                // TODO: Remove sleep to make migration slower
                sleep(2)
                guard let plant = _plant as? PlantEntity else {
                    let error = "Object in PlantArray is not PlantEntity: \(_plant)"
                    log.error(error)
                    assertionFailure(error)
                    return
                }
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
                    let description = "Error while migrating plant named: \(vesselName!): \(error)"
                    log.error(description)
                    assertionFailure(description)
                case .success:
                    migrated += 1
                }
            }
            self.deleteCoreDataStoreWithoutMigrating()
            DispatchQueue.main.async {
                completion(migrated == count)
            }
        }
    }

    private func moveCoreDataStoreToPostMigrationLocation() throws {
        let fm = FileManager.default
        let destinationDir = type(of: self).storeDirectoryPostMigration
        let filesToMove = type(of: self).storeFilesToMove
        var isDir: ObjCBool = false
        let exists = fm.fileExists(atPath: destinationDir.path, isDirectory: &isDir)
        switch (exists, isDir.boolValue) {
        case (true, false):
            try fm.removeItem(at: destinationDir)
            fallthrough
        case (false, _):
            try fm.createDirectory(at: destinationDir, withIntermediateDirectories: false, attributes: nil)
            fallthrough
        case (true, true):
            try filesToMove.forEach() { sourceURL in
                let destination = destinationDir.appendingPathComponent(sourceURL.lastPathComponent)
                try fm.moveItem(at: sourceURL, to: destination)
            }
        }
    }

    func deleteCoreDataStoreWithoutMigrating() {
        do {
            try self.moveCoreDataStoreToPostMigrationLocation()
        } catch {
            let message = "Error Moving Core Data Store Files: \(error)"
            log.error(message)
            assertionFailure(message)
        }
    }
}

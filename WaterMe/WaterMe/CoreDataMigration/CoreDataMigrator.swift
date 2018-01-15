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

import WaterMeData
import Crashlytics
import CoreData
import Foundation

protocol CoreDataMigratable {
    var progress: Progress { get }
    func start(with: BasicController, completion: @escaping (Bool) -> Void)
    func deleteCoreDataStoreWithoutMigrating()
}

class CoreDataMigrator: CoreDataMigratable {

    // MARK: Core Data Locations on Disk

    private static let momName = "WaterMeData"
    private static let storeURL = CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite")
    private static let storeDirectoryPostMigration = CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMe1.coredata", isDirectory: true)
    fileprivate static let storeDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeDirectory = appSupport.appendingPathComponent("WaterMe", isDirectory: true)
        return storeDirectory
    }()
    private static let storeFilesToMove: [URL] = {
        return [
            CoreDataMigrator.storeURL,
            CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite-shm"),
            CoreDataMigrator.storeDirectory.appendingPathComponent("WaterMeData.sqlite-wal")
        ]
    }()

    // MARK: Properties

    private let container: NSPersistentContainer
    let progress = Progress()

    // MARK: Helper for Counting Plants

    private var numberOfPlantsToMigrate: Int? {
        do {
            return try self.container.viewContext.count(for: NSFetchRequest(entityName: String(describing: PlantEntity.self)))
        } catch {
            let message = "CoreDataError Fetching Count of old plants: \(error)"
            log.error(message)
            Crashlytics.sharedInstance().recordError(error)
            assertionFailure(message)
            return nil
        }
    }

    // MARK: Init

    // Looks for a core data file on disk. If it exists, that means the user upgraded from WaterMe 1
    // If it exists, initialization succeeds. Otherwise, it returns NIL
    init?() {
        let sqLiteURL = CoreDataMigrator.storeURL
        // if the file doesn't exist then they never had the old version of the app.
        guard FileManager.default.fileExists(atPath: sqLiteURL.path) == true else { return nil }
        self.container = WaterMePersistentContainer(name: CoreDataMigrator.momName)
        self.container.persistentStoreDescriptions.first?.isReadOnly = true
        self.container.loadPersistentStores() { _, error  in
            guard error == nil else {
                let message = "Error Loading Core Data Model. This leaves the Migrator in an invalid state: \(error!)"
                log.error(message)
                Crashlytics.sharedInstance().recordError(error!)
                assertionFailure(message)
                return
            }
            let count = self.numberOfPlantsToMigrate
            self.progress.totalUnitCount = Int64(count ?? -1)
            self.progress.completedUnitCount = 0
        }
        log.debug("Loaded Core Data Stack: Ready for Migration.")
    }

    // MARK: Perform the Migration

    // This function just loads the data from Core Data and iterates over it
    // Each iteration it creates a new object in REALM
    // It also updates the progress object
    // Finally it shuts down the core data stack and moves the underlying files
    // Moving the files means the data is not lost but its not detected on next boot
    // Which means it won't try to migrate again.
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
            var plants = type(of: self).plants(from: c)
            // weird loop so core data memory can be drained in each iteration
            for _ in 0 ..< plants.count {
                autoreleasepool() {
                    // needs more testing but the ReminderGedeg was sometimes
                    // crashing when migration happened at full speed
                    Thread.sleep(forTimeInterval: 0.1)
                    // popping them out of the array allows the memory to be freed in the release pool
                    let _plant = plants.popLast()
                    guard let plant = _plant as? PlantEntity else {
                        let error = "Object in PlantArray is not PlantEntity: \(String(describing: _plant))"
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
            }
            self.closeCoreDataStoresAndMoveUnderlyingFiles()
            DispatchQueue.main.async {
                if migrated == count {
                    Analytics.log(event: Analytics.CoreDataMigration.migrationComplete,
                                  extras: Analytics.CoreDataMigration.extras(migrated: migrated, total: count))
                } else {
                    Analytics.log(event: Analytics.CoreDataMigration.migrationPartial,
                                  extras: Analytics.CoreDataMigration.extras(migrated: migrated, total: count))
                }
                completion(migrated == count)
            }
        }
    }

    func deleteCoreDataStoreWithoutMigrating() {
        self.closeCoreDataStoresAndMoveUnderlyingFiles()
    }

    // MARK: Helper functions for capturing errors

    private func closeCoreDataStoresAndMoveUnderlyingFiles() {
        do {
            // close all the stores before moving the files
            try self.container.persistentStoreCoordinator.persistentStores.forEach() {
                try self.container.persistentStoreCoordinator.remove($0)
            }
            // move the underlying files
            try type(of: self).moveCoreDataStoreToPostMigrationLocation()
        } catch {
            let message = "Error Moving Core Data Store Files: \(error)"
            log.error(message)
            Crashlytics.sharedInstance().recordError(error)
            assertionFailure(message)
        }
    }

    private class func plants(from c: NSManagedObjectContext) -> [Any] {
        do {
            return try c.fetch(NSFetchRequest(entityName: String(describing: PlantEntity.self)))
        } catch {
            let message = "CoreDataError Fetching old plants: \(error)"
            log.error(message)
            Crashlytics.sharedInstance().recordError(error)
            assertionFailure(message)
            return []
        }
    }

    // MARK: Move the underlying files

    // Checks to see if there is a location on disk to move the files to
    // If not, it makes a folder. If a file exists with the same name as folder
    // It deletes the file and then makes the folder
    // Lastly it moves the core data files there
    private class func moveCoreDataStoreToPostMigrationLocation() throws {
        let fm = FileManager.default
        let destinationDir = self.storeDirectoryPostMigration
        let filesToMove = self.storeFilesToMove
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
}

// MARK: Custom Subclass of NSPersistentContainer

// Subclass needed to give Core Data my custom directory from WaterMe1
private class WaterMePersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return CoreDataMigrator.storeDirectory
    }
}

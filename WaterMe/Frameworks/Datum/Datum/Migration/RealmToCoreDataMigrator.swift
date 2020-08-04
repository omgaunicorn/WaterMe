//
//  RealmToCoreDataMigrator.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/08/01.
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
import RealmSwift

internal class RealmToCoreDataMigrator: Migratable {

    private var source: RLM_BasicController?
    private let queue = DispatchQueue(label: "RealmToCoreDataMigrator", qos: .userInitiated)

    /// If `testingSource` is `NIL` class checks if local realm DB exists.
    /// If it does exist, then it creates a RLM_BasicController and initializes.
    /// If it does not exist it returns `NIL`
    /// If a `testingSource` is provided, then no checks are performed
    /// and the class always initializes.
    init?(testingSource: RLM_BasicController? = nil) {
        if let source = testingSource {
            self.source = source
        } else {
            guard
                RLM_BasicController.storeExists,
                let source = try? RLM_BasicController(kind: .local, forTesting: false)
            else { return nil }
            self.source = source
        }
    }

    func skipMigration() -> MigratableResult {
        do {
            try FileManager.default.removeItem(at: RLM_BasicController.storeDirectoryURL)
            self.source = nil
            return .success(())
        } catch {
            return .failure(.skipError)
        }
    }

    @discardableResult func start(destination: BasicController,
                                  completion: @escaping (MigratableResult) -> Void) -> Progress
    {
        let progress = Progress(totalUnitCount: 0)
        progress.completedUnitCount = 0
        guard
            let source = self.source,
            let destination = destination as? CD_BasicController
        else {
            DispatchQueue.main.async { completion(.failure(.loadError)) }
            return progress
        }

        // Get off main thread
        self.queue.async {

            // Get needed contexts and realms
            let context = destination.container.newBackgroundContext()
            guard
                let realm = try? source.realm.get(),
                let rhsShare = (try? context.fetch(CD_VesselShare.request))?.first
            else {
                DispatchQueue.main.async { completion(.failure(.loadError)) }
                return
            }

            // Get our Data to work with
            var srcVessels = Array(realm.objects(RLM_ReminderVessel.self))
            log.debug("Vessels to Migrate: \(srcVessels.count)")
            let totalUnitCount = Int64(srcVessels.count)
            progress.totalUnitCount = totalUnitCount
            var srcVessel: RLM_ReminderVessel! = srcVessels.popLast()

            // Loop over every vessel
            var completedUnitCount: Int64 = 0
            while srcVessel != nil {
                autoreleasepool {
                    defer {
                        // Prepare for next loop
                        do {
                            try context.save()
                            completedUnitCount += 1
                            progress.completedUnitCount = completedUnitCount
                            srcVessel = srcVessels.popLast()
                            log.debug("Vessels to Migrate: \(srcVessels.count)")
                        } catch {
                            log.error(error)
                            srcVessel = nil
                        }
                    }

                    // Vessel: Configure
                    let destVessel = CD_ReminderVessel(context: context)
                    context.insert(destVessel)

                    _ = {
                        // Vessel: Copy Data
                        destVessel.share = rhsShare
                        destVessel.displayName = srcVessel.displayName
                        destVessel.iconImageData = srcVessel.iconImageData
                        destVessel.iconEmojiString = srcVessel.iconEmojiString
                        destVessel.kindString = srcVessel.kindString
                    }()

                    for srcReminder in srcVessel.reminders {
                        // Reminder: Configure
                        let destReminder = CD_Reminder(context: context)
                        destReminder.vessel = destVessel
                        context.insert(destReminder)

                        _ = {
                            // Reminder: Copy Data
                            destReminder.interval = Int32(srcReminder.interval)
                            destReminder.note = srcReminder.note
                            destReminder.nextPerformDate = srcReminder.nextPerformDate
                            destReminder.lastPerformDate = srcReminder.performed.last?.date
                            destReminder.kindString = srcReminder.kindString
                            destReminder.descriptionString = srcReminder.descriptionString
                        }()

                        for srcPerform in srcReminder.performed {
                            // Perform: Configure
                            let destPerform = CD_ReminderPerform(context: context)
                            destPerform.reminder = destReminder
                            context.insert(destPerform)

                            _ = {
                                // Perform: Copy Data
                                destPerform.date = srcPerform.date
                            }()
                        }
                    }
                }
            }

            // check if we completed by comparing completion count
            var completed = completedUnitCount == totalUnitCount

            // do cleanup tasks only if we are not using unit tests
            if !TESTING {
                if completed {
                    // Cleanup source, this HAS to work for migration to finish
                    do {
                        try FileManager.default.removeItem(at: RLM_BasicController.storeDirectoryURL)
                        log.info("Migration Succeeded")
                    } catch {
                        log.error("Migration Error: Succeeded but failed to delete Realm DB: \(error)")
                        completed = false
                    }
                } else {
                    // If we didn't complete, try to clean up the destination
                    // Don't clean up destination if source failed to delete
                    // Too risky, might lose data
                    for vessel in rhsShare.vessels {
                        guard let vessel = vessel as? NSManagedObject else { continue }
                        context.delete(vessel)
                    }
                    do {
                        try context.save()
                        log.error("Migration Failed: Successfully cleaned up Core Data")
                    } catch {
                        log.error("Migration Failed: Failed to clean up Core Data: \(error)")
                    }
                }
            }

            if completed {
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                DispatchQueue.main.async { completion(.failure(.migrateError)) }
            }
        }
        return progress
    }
}

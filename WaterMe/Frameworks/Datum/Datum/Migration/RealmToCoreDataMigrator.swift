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

    init?(source: BasicController? = nil, forTesting: Bool = false) {
        guard !forTesting else {
            self.source = (source as? RLM_BasicController)!
            return
        }

        let _source = (source as? RLM_BasicController)
                      ?? (try? RLM_BasicController(kind: .local, forTesting: false))
        guard
            RLM_BasicController.localRealmExists,
            let source = _source
        else { return nil }
        self.source = source
    }

    func skipMigration() -> MigratableResult {
        do {
            try FileManager.default.removeItem(at: RLM_BasicController.localRealmDirectory)
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
            let destination = destination as? CD_BasicController,
            source !== destination
        else {
            DispatchQueue.main.async { completion(.failure(.loadError)) }
            return progress
        }

        // Get off main thread
        self.queue.async {

            // Get needed contexts and realms
            let context = destination.container.newBackgroundContext()
            let _rhsShare: CD_VesselShare? = {
                let request = CD_VesselShare.request
                let result = try? context.fetch(request)
                return result?.first
            }()
            guard
                let realm = try? source.realm.get(),
                let rhsShare = _rhsShare
            else {
                DispatchQueue.main.async { completion(.failure(.loadError)) }
                return
            }

            // Get our Data to work with
            var srcVessels = Array(realm.objects(RLM_ReminderVessel.self))
            progress.totalUnitCount = Int64(srcVessels.count)
            var srcVessel: RLM_ReminderVessel! = srcVessels.popLast()

            // Loop over every vessel
            while srcVessel != nil {
                autoreleasepool {
                    defer {
                        // Prepare for next loop
                        do {
                            try context.save()
                            srcVessel = srcVessels.popLast()
                            progress.completedUnitCount += 1
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

            // Loop complete, we're done
            if srcVessels.isEmpty {
                DispatchQueue.main.async { completion(.success(())) }
            } else {
                DispatchQueue.main.async { completion(.failure(.migrateError)) }
            }
        }
        return progress
    }
}

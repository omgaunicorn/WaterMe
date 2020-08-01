//
//  DummyMigrator.swift
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

internal class DummyMigrator: Migratable {

    func start(destination: BasicController, completion: @escaping (Bool) -> Void) -> Progress {
        let progress = Progress(totalUnitCount: 10)
        progress.completedUnitCount = 0
        var current: Int64 = 0
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard current <= 10 else {
                timer.invalidate()
                completion(true)
                return
            }
            current += 1
            progress.completedUnitCount = current
        }
        return progress
    }

    func skipMigration() {

    }
}

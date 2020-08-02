//
//  RealmToCoreDataMigratorTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/08/02.
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

import XCTest
import CoreData
@testable import Datum

class RealmToCoreDataMigratorBaseTests: XCTestCase {

    let source: BasicController = try! RLM_BasicController(kind: .local, forTesting: true)
    let destination: CD_BasicController = try! CD_BasicController(kind: .local, forTesting: true)

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        let realmDir = RLM_BasicController.localRealmDirectory
        let coreDataDir = CD_BasicController.dbDirectoryURL
        let fm = FileManager.default
        try? fm.removeItem(at: realmDir)
        try? fm.removeItem(at: coreDataDir)
    }
}

class RealmToCoreDataMigratorAccuracyTests: RealmToCoreDataMigratorBaseTests {

    override func setUpWithError() throws {
        try super.setUpWithError()

        let v_1 = try source.newReminderVessel(displayName: "One", icon: .emoji("1️⃣")).get()
        let v_2 = try source.newReminderVessel(displayName: "Two", icon: nil).get()
        let v_3 = try source.newReminderVessel(displayName: "Three", icon: .emoji("3️⃣")).get()

        let v_1_r_1 = try source.newReminder(for: v_1).get()
        let v_1_r_2 = try source.newReminder(for: v_1).get()
        let v_1_r_3 = try source.newReminder(for: v_1).get()

        try source.update(kind: .mist, interval: 1, note: nil, in: v_1_r_1).get()
        try source.update(kind: .fertilize, interval: 10, note: nil, in: v_1_r_2).get()
        try source.update(kind: .move(location: "Over There"), interval: 100, note: "This is a Note", in: v_1_r_3).get()

        let v_2_r_1 = try source.newReminder(for: v_2).get()
        let v_2_r_2 = try source.newReminder(for: v_2).get()
        let v_2_r_3 = try source.newReminder(for: v_2).get()

        try source.update(kind: .water, interval: -1, note: nil, in: v_2_r_1).get()
        try source.update(kind: .trim, interval: -10, note: nil, in: v_2_r_2).get()
        try source.update(kind: .other(description: nil), interval: -100, note: "This is a Note", in: v_2_r_3).get()

        let v_3_r_1 = try source.newReminder(for: v_3).get()
        let v_3_r_2 = try source.newReminder(for: v_3).get()
        let v_3_r_3 = try source.newReminder(for: v_3).get()

        try source.update(kind: .move(location: "One"), interval: 10000000, note: "One", in: v_3_r_1).get()
        try source.update(kind: .move(location: "Two"), interval: 100000000, note: "Two", in: v_3_r_2).get()
        try source.update(kind: .move(location: "Three"), interval: 1000000000, note: "Three", in: v_3_r_3).get()

        let allReminders = [v_1_r_1, v_1_r_2, v_1_r_3, v_2_r_1, v_2_r_2, v_2_r_3, v_3_r_1, v_3_r_2, v_3_r_3]
                           .map { Identifier(rawValue: $0.uuid) }
        try source.appendNewPerformToReminders(with: allReminders).get()
        try source.appendNewPerformToReminders(with: allReminders).get()
        try source.appendNewPerformToReminders(with: allReminders).get()
    }

    func test_migrationAccuracy() {
        let context = self.destination.container.viewContext
        let req_v = NSFetchRequest<CD_ReminderVessel>(entityName: "CD_ReminderVessel")
        let req_r = NSFetchRequest<CD_Reminder>(entityName: "CD_Reminder")
        let req_p = NSFetchRequest<CD_ReminderPerform>(entityName: "CD_ReminderPerform")
        XCTAssertEqual(try? context.fetch(req_v).count, 0)
        XCTAssertEqual(try? context.fetch(req_r).count, 0)
        XCTAssertEqual(try? context.fetch(req_p).count, 0)

        let migrator = RealmToCoreDataMigrator(source: self.source, forTesting: true)!
        let wait1 = XCTestExpectation()
        wait1.expectedFulfillmentCount = 1
        let progress = migrator.start(destination: self.destination) { result in
            wait1.fulfill()
            switch result {
            case .success:
                let vessels = try! context.fetch(req_v)
                XCTAssertEqual(vessels.count, 3)
                XCTAssertEqual(try? context.fetch(req_r).count, 12)
                XCTAssertEqual(try? context.fetch(req_p).count, 27)

                let v_1 = vessels.filter({ $0.displayName == "One" }).first!
                let v_2 = vessels.filter({ $0.displayName == "Two" }).first!
                let v_3 = vessels.filter({ $0.displayName == "Three" }).first!

                XCTAssertEqual(v_1.icon?.emoji, "1️⃣")
                XCTAssertNil(v_2.icon)
                XCTAssertEqual(v_3.icon?.emoji, "3️⃣")

                let v_1_r_1 = (v_1.reminders as! Set<CD_Reminder>).filter({ $0.interval == 1 }).first!
                let v_1_r_2 = (v_1.reminders as! Set<CD_Reminder>).filter({ $0.interval == 10 }).first!
                let v_1_r_3 = (v_1.reminders as! Set<CD_Reminder>).filter({ $0.interval == 100 }).first!

                XCTAssertEqual(v_1_r_1.kind, .mist)
                XCTAssertEqual(v_1_r_2.kind, .fertilize)
                XCTAssertEqual(v_1_r_3.kind, .move(location: "Over There"))

                XCTAssertNil(v_1_r_1.note)
                XCTAssertNil(v_1_r_2.note)
                XCTAssertEqual(v_1_r_3.note, "This is a Note")

                let v_2_r_1 = (v_2.reminders as! Set<CD_Reminder>).filter({ $0.interval == -1 }).first!
                let v_2_r_2 = (v_2.reminders as! Set<CD_Reminder>).filter({ $0.interval == -10 }).first!
                let v_2_r_3 = (v_2.reminders as! Set<CD_Reminder>).filter({ $0.interval == -100 }).first!

                XCTAssertEqual(v_2_r_1.kind, .water)
                XCTAssertEqual(v_2_r_2.kind, .trim)
                XCTAssertEqual(v_2_r_3.kind, .other(description: nil))

                XCTAssertNil(v_2_r_1.note)
                XCTAssertNil(v_2_r_2.note)
                XCTAssertEqual(v_2_r_3.note, "This is a Note")

                let v_3_r_1 = (v_3.reminders as! Set<CD_Reminder>).filter({ $0.interval == 10000000 }).first!
                let v_3_r_2 = (v_3.reminders as! Set<CD_Reminder>).filter({ $0.interval == 100000000 }).first!
                let v_3_r_3 = (v_3.reminders as! Set<CD_Reminder>).filter({ $0.interval == 1000000000 }).first!

                XCTAssertEqual(v_3_r_1.kind, .move(location: "One"))
                XCTAssertEqual(v_3_r_2.kind, .move(location: "Two"))
                XCTAssertEqual(v_3_r_3.kind, .move(location: "Three"))

                XCTAssertEqual(v_3_r_1.note, "One")
                XCTAssertEqual(v_3_r_2.note, "Two")
                XCTAssertEqual(v_3_r_3.note, "Three")

                let allReminders = [v_1_r_1, v_1_r_2, v_1_r_3, v_2_r_1, v_2_r_2, v_2_r_3, v_3_r_1, v_3_r_2, v_3_r_3]
                XCTAssertEqual(allReminders.filter({ $0.performed.count == 3 }).count, allReminders.count)
            case .failure(let error):
                XCTFail("Migration failed with error: \(error)")
            }
        }

        let wait2 = XCTestExpectation()
        wait2.expectedFulfillmentCount = 3
        self.token = progress.observe(\.fractionCompleted) { _, _ in
            wait2.fulfill()
            print(progress.fractionCompleted)
        }

        self.wait(for: [wait1, wait2], timeout: 3)
    }

    private var token: NSKeyValueObservation?

}

class RealmToCoreDataMigratorScaleTests: RealmToCoreDataMigratorBaseTests {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

}

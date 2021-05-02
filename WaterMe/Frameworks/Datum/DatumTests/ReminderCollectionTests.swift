//
//  ReminderCollectionTests.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/28.
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
@testable import Datum

class ReminderCollectionTests: DatumTestsBase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try self.setUpSmall()
    }
    
    func test_load() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let count = data.count
            XCTAssertEqual(count, 8)
            XCTAssertEqual(data[count-1]!.note!, "Vessel: 200番花: Reminder: 300")
        }
        self.wait(for: [wait], timeout: 0.1)
    }
    
    func test_map() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let preCount = data.count
            let mapped: [String?] = data.map() { $0!.note }
            XCTAssertEqual(preCount, mapped.count)
            XCTAssertNil(mapped[0])
            XCTAssertEqual(mapped[preCount-1]!, data[preCount-1]!.note!)
        }
        self.wait(for: [wait], timeout: 0.1)
    }
    
    func test_compactMap() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let preCount = data.count
            let mapped: [String] = data.compactMap() { $0!.note }
            XCTAssertEqual(mapped.count, preCount-2) // 2 of the notes in this collection are nil
            XCTAssertEqual(mapped.last!, data[preCount-1]!.note!)
        }
        self.wait(for: [wait], timeout: 0.1)
    }
    
    func test_indexOfItem() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        let inputIndex = 3
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let input = data[inputIndex]!
            let outputIndex = data.index(of: input)!
            let output = data[outputIndex]!
            XCTAssertEqual(outputIndex, inputIndex)
            XCTAssertEqual(input.uuid, output.uuid)
        }
        self.wait(for: [wait], timeout: 0.1)
    }
    
    func test_indexOfIdentifier() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        let inputIndex = 3
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let input = data[inputIndex]!
            let inputIdentifier = Identifier(rawValue: input.uuid)
            let outputIndex = data.indexOfItem(with: inputIdentifier)!
            let output = data[outputIndex]!
            XCTAssertEqual(outputIndex, inputIndex)
            XCTAssertEqual(input.uuid, output.uuid)
        }
        self.wait(for: [wait], timeout: 0.1)
    }
    
    func test_update_modifications() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let reminder = try! self.basicController.newReminder(for: vessel).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_receiveUpdates() { (_, changes) in
            wait.fulfill()
            XCTAssertEqual(changes.insertions.count, 0)
            XCTAssertEqual(changes.modifications.count, 1)
            XCTAssertEqual(changes.deletions.count, 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(kind: .mist, interval: 10, isEnabled: true, note: "a new note", in: reminder).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
    
    func test_update_deletions() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_receiveUpdates() { (_, changes) in
            wait.fulfill()
            XCTAssertEqual(changes.insertions.count, 0)
            XCTAssertEqual(changes.modifications.count, 0)
            XCTAssertEqual(changes.deletions.count, 1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.delete(vessel: vessel).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
    
    func test_update_insert() {
        let query = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        self.token = query.test_observe_receiveUpdates() { (_, changes) in
            wait.fulfill()
            XCTAssertEqual(changes.insertions.count, 1)
            XCTAssertEqual(changes.modifications.count, 0)
            XCTAssertEqual(changes.deletions.count, 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}

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
    
    func test_loadReminderCollection() {
        let query = try! self.basicController.allReminders(sorted: .nextPerformDate, ascending: true).get()
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
        let query = try! self.basicController.allReminders(sorted: .nextPerformDate, ascending: true).get()
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
        let query = try! self.basicController.allReminders(sorted: .nextPerformDate, ascending: true).get()
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
    
    func test_indexOfReminder() {
        let query = try! self.basicController.allReminders(sorted: .nextPerformDate, ascending: true).get()
        let wait = XCTestExpectation()
        let inputIndex = 3
        self.token = query.test_observe_loadData() { data in
            wait.fulfill()
            let inputReminder = data[inputIndex]!
            let outputIndex = data.index(of: inputReminder)!
            let outputReminder = data[outputIndex]!
            XCTAssertEqual(outputIndex, inputIndex)
            XCTAssertEqual(inputReminder.uuid, outputReminder.uuid)
        }
        self.wait(for: [wait], timeout: 0.1)
    }
    
}

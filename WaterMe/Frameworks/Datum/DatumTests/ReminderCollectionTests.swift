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
    
}

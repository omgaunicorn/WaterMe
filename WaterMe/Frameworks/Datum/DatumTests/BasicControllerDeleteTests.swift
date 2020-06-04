//
//  BasicControllerDeleteTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/06/02.
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

class BasicControllerDeleteTests: DatumTestsBase {
    
//    func delete(vessel: ReminderVessel) -> Result<Void, DatumError>
    
    func test_delete_vessel() {
        let item = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let wait = XCTestExpectation()
        self.token = item.observe { change in
            switch change {
            case .change:
                // Core Data is still firing updates after
                // deletions. Not sure how to spot it.
                break
            case .deleted:
                wait.fulfill()
            case .error:
                XCTFail()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.delete(vessel: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
    
    //    func delete(reminder: Reminder) -> Result<Void, DatumError>
    
    func test_delete_reminder() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        let wait = XCTestExpectation()
        self.token = item.observe { change in
            switch change {
            case .change:
                XCTFail()
            case .deleted:
                wait.fulfill()
            case .error:
                XCTFail()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.delete(reminder: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }

}

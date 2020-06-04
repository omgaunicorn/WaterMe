//
//  ModelTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/06/03.
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

class ReminderVesselTests: DatumTestsBase {
    
    func test_nilValues_vessel() {
        let item = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        XCTAssertEqual(item.kind, .plant)
        XCTAssertNil(item.displayName)
        XCTAssertNil(item.icon)
    }
    
    func test_realValues_vessel() {
        let item = try! self.basicController.newReminderVessel(displayName: "お花水",
                                                               icon: .emoji("🌵")).get()
        XCTAssertEqual(item.kind, .plant)
        XCTAssertEqual(item.displayName, "お花水")
        XCTAssertEqual(item.icon?.emoji, "🌵")
    }
    
    func test_updateName_vessel() {
        let item = try! self.basicController.newReminderVessel(displayName: "お花水",
                                                               icon: .emoji("🌵")).get()
        let wait = XCTestExpectation()
        self.token = item.observe() { change in
            switch change {
            case .change(let change):
                XCTAssertTrue(change.changedDisplayName)
                XCTAssertFalse(change.changedIconEmoji)
                XCTAssertFalse(change.changedReminders)
                XCTAssertFalse(change.changedPointlessBloop)
                XCTAssertEqual(item.kind, .plant)
                XCTAssertEqual(item.displayName, "ええええ")
                XCTAssertEqual(item.icon?.emoji, "🌵")
            case .deleted, .error:
                XCTFail()
            }
            wait.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(displayName: "ええええ", icon: nil, in: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
    
    func test_updateIcon_vessel() {
        let item = try! self.basicController.newReminderVessel(displayName: "お花水",
                                                               icon: .emoji("🌵")).get()
        let wait = XCTestExpectation()
        self.token = item.observe() { change in
            switch change {
            case .change(let change):
                XCTAssertTrue(change.changedIconEmoji)
                XCTAssertFalse(change.changedDisplayName)
                XCTAssertFalse(change.changedReminders)
                XCTAssertFalse(change.changedPointlessBloop)
                XCTAssertEqual(item.kind, .plant)
                XCTAssertEqual(item.displayName, "お花水")
                XCTAssertEqual(item.icon?.emoji, "🧗‍♂️")
            case .deleted, .error:
                XCTFail()
            }
            wait.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(displayName: nil, icon: .emoji("🧗‍♂️"), in: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}

extension CD_ReminderVesselTests {
    func test_updateReminders_vessel() {
        let item = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let wait = XCTestExpectation()
        wait.expectedFulfillmentCount = 3
        var hitCount = 0
        self.token = item.observeReminders { changes in
            switch changes {
            case .initial(let data):
                switch hitCount {
                case 0:
                    XCTAssertEqual(data.count, 1)
                default:
                    XCTFail()
                }
            case .update(let changes):
                switch hitCount {
                case 1:
                    XCTAssertEqual(changes.insertions.count, 1)
                    XCTAssertEqual(changes.modifications.count, 0)
                    XCTAssertEqual(changes.deletions.count, 0)
                case 2:
                    XCTAssertEqual(changes.insertions.count, 0)
                    XCTAssertEqual(changes.modifications.count, 1)
                    XCTAssertEqual(changes.deletions.count, 0)
                default:
                    XCTFail()
                }
            case .error:
                XCTFail()
            }
            hitCount += 1
            wait.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = try! self.basicController.newReminder(for: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}

extension RLM_ReminderVesselTests {
    func test_updateReminders_vessel() {
        let item = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let wait = XCTestExpectation()
        wait.expectedFulfillmentCount = 2
        self.token = item.observeReminders { changes in
            switch changes {
            case .initial(let data):
                XCTAssertEqual(data.count, 1)
            case .update(let changes):
                XCTAssertEqual(changes.insertions.count, 1)
                XCTAssertEqual(changes.modifications.count, 0)
                XCTAssertEqual(changes.deletions.count, 0)
            case .error:
                XCTFail()
            }
            wait.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            _ = try! self.basicController.newReminder(for: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}

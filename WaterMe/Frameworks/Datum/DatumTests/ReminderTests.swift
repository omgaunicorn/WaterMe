//
//  ReminderTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/06/04.
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
import Calculate
@testable import Datum

class ReminderTests: DatumTestsBase {
    
    func test_nilValues() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        XCTAssertEqual(item.kind, .water)
        XCTAssertEqual(item.interval, 7)
        XCTAssertNil(item.note)
        XCTAssertNil(item.nextPerformDate)
        XCTAssertNil(item.lastPerformDate)
        XCTAssertNil(item.isModelComplete)
        XCTAssertEqual(item.vessel!.uuid, vessel.uuid)
    }
    
    func test_modelComplete() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item1 = try! self.basicController.newReminder(for: vessel).get()
        let item2 = try! self.basicController.newReminder(for: vessel).get()
        try! self.basicController.update(kind: .move(location: nil), interval: nil, note: nil, in: item1).get()
        try! self.basicController.update(kind: .other(description: nil), interval: nil, note: nil, in: item2).get()
        let item1Error = item1.isModelComplete
        let item2Error = item2.isModelComplete
        XCTAssertNotNil(item1Error)
        XCTAssertNotNil(item2Error)
        XCTAssertEqual(item1Error?._actions[0], .reminderMissingMoveLocation)
        XCTAssertEqual(item1Error?._actions[1], .cancel)
        XCTAssertEqual(item1Error?._actions[2], .saveAnyway)
        XCTAssertEqual(item2Error?._actions[0], .reminderMissingOtherDescription)
        XCTAssertEqual(item2Error?._actions[1], .cancel)
        XCTAssertEqual(item2Error?._actions[2], .saveAnyway)
    }
    
    func test_updateName_vessel() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil,
                                                               icon: nil).get()
        let item = try! self.basicController.newReminder(for: vessel).get()
        let wait = XCTestExpectation()
        self.token = item.observe() { change in
            switch change {
            case .change:
                XCTAssertEqual(item.kind, .mist)
                XCTAssertEqual(item.interval, 4)
                XCTAssertEqual(item.note, "A Cool Note")
            case .deleted, .error:
                XCTFail()
            }
            wait.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try! self.basicController.update(kind: .mist, interval: 4, note: "A Cool Note", in: item).get()
        }
        self.wait(for: [wait], timeout: 0.3)
    }
}

extension RLM_ReminderTests {
    func test_perform_dates() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let _item = try! self.basicController.newReminder(for: vessel).get()
        let item = (_item as! RLM_ReminderWrapper).wrappedObject
        XCTAssertEqual(item.performed.count, 0)
        let now = Date()
        let future = Calendar.current.dateByAddingNumberOfDays(_item.interval, to: now)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: _item.uuid)]).get()
        XCTAssertEqual(item.performed.count, 1)
        let perform = item.performed.first!
        XCTAssertDatesClose(perform.date, now, within: 1)
        XCTAssertDatesClose(_item.lastPerformDate!, now, within: 1)
        XCTAssertDatesClose(_item.nextPerformDate!, future, within: 1)
    }
}

extension CD_ReminderTests {
    func test_perform_dates() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let _item = try! self.basicController.newReminder(for: vessel).get()
        let item = (_item as! CD_ReminderWrapper).wrappedObject
        XCTAssertEqual(item.performed.count, 0)
        let now = Date()
        let future = Calendar.current.dateByAddingNumberOfDays(_item.interval, to: now)
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: _item.uuid)]).get()
        XCTAssertEqual(item.performed.count, 1)
        let perform = item.performed.allObjects.first! as! CD_ReminderPerform
        XCTAssertDatesClose(perform.date, now, within: 1)
        XCTAssertDatesClose(_item.lastPerformDate!, now, within: 1)
        XCTAssertDatesClose(_item.nextPerformDate!, future, within: 1)
    }
}

public func XCTAssertDatesClose(_ expression1: @autoclosure () throws -> Date,
                                _ expression2: @autoclosure () throws -> Date,
                                within interval:  TimeInterval,
                                _ message: @autoclosure () -> String = "",
                                file: StaticString = #file,
                                line: UInt = #line)
{
    do {
        let date1 = try expression1()
        let date2 = try expression2()
        let gap = date1.timeIntervalSince(date2)
        let gapABS = abs(gap)
        guard gapABS > interval else { return }
        XCTAssertEqual(date1, date2, message(), file: file, line: line)
    }  catch {
        XCTFail(error.localizedDescription)
    }
}

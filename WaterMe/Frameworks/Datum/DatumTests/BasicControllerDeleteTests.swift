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

import CoreData

extension CD_BasicControllerDeleteTests {
    func test_vessel_cascadingDeletes() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let reminder = try! self.basicController.newReminder(for: vessel).get()
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
        let bc = self.basicController as! CD_BasicController
        let context = bc.container.viewContext
        let vesselReq = CD_ReminderVessel.request
        let reminderReq = CD_Reminder.request
        let performReq = CD_ReminderPerform.request

        let vesselRes1 = try! context.fetch(vesselReq)
        let reminderRes1 = try! context.fetch(reminderReq)
        let performRes1 = try! context.fetch(performReq)

        XCTAssertEqual(vesselRes1.count, 1)
        XCTAssertEqual(reminderRes1.count, 2)
        XCTAssertEqual(performRes1.count, 1)

        try! self.basicController.delete(vessel: vessel).get()

        let vesselRes2 = try! context.fetch(vesselReq)
        let reminderRes2 = try! context.fetch(reminderReq)
        let performRes2 = try! context.fetch(performReq)

        XCTAssertEqual(vesselRes2.count, 0)
        XCTAssertEqual(reminderRes2.count, 0)
        XCTAssertEqual(performRes2.count, 0)
    }

    func test_reminder_cascadingDeletes() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let reminder = try! self.basicController.newReminder(for: vessel).get()
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
        let bc = self.basicController as! CD_BasicController
        let context = bc.container.viewContext
        let vesselReq = CD_ReminderVessel.request
        let reminderReq = CD_Reminder.request
        let performReq = CD_ReminderPerform.request

        let vesselRes1 = try! context.fetch(vesselReq)
        let reminderRes1 = try! context.fetch(reminderReq)
        let performRes1 = try! context.fetch(performReq)

        XCTAssertEqual(vesselRes1.count, 1)
        XCTAssertEqual(reminderRes1.count, 2)
        XCTAssertEqual(performRes1.count, 1)

        try! self.basicController.delete(reminder: reminder).get()

        let vesselRes2 = try! context.fetch(vesselReq)
        let reminderRes2 = try! context.fetch(reminderReq)
        let performRes2 = try! context.fetch(performReq)

        XCTAssertEqual(vesselRes2.count, 1)
        XCTAssertEqual(reminderRes2.count, 1)
        XCTAssertEqual(performRes2.count, 0)
    }

    func test_delete_last_reminder() {
        let exp = self.expectation(description: "")
        exp.expectedFulfillmentCount = 3
        var hitCount = 0
        var _data: AnyCollection<Reminder, Int>!
        _ = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        self.token = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get().observe
        { change in
            switch change {
            case .initial(let data):
                _data = data
                exp.fulfill()
                XCTAssertEqual(data.count, 1)
                let result = self.basicController.delete(reminder: data[0]!)
                switch result {
                case .success:
                    XCTFail()
                case .failure(let error):
                    XCTAssertEqual(error, .unableToDeleteLastReminder)
                    XCTAssertEqual(data.count, 0)
                }
            case .update(let change):
                // Test an implementation detail of CD
                // where the item is deleted for a split second
                // then is rolled back
                switch hitCount {
                case 0:
                    XCTAssertTrue(change.insertions.isEmpty)
                    XCTAssertEqual(change.deletions.count, 1)
                    XCTAssertTrue(change.modifications.isEmpty)
                    XCTAssertEqual(_data.count, 0)
                case 1:
                    XCTAssertEqual(change.insertions.count, 1)
                    XCTAssertTrue(change.deletions.isEmpty)
                    XCTAssertTrue(change.modifications.isEmpty)
                    XCTAssertEqual(_data.count, 1)
                default:
                    XCTFail()
                }
                exp.fulfill()
                hitCount += 1
            case .error:
                XCTFail()
            }
        }
        self.wait(for: [exp], timeout: 0.5)
    }
}

import RealmSwift

extension RLM_BasicControllerDeleteTests {
    func test_vessel_cascadingDeletes() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let reminder = try! self.basicController.newReminder(for: vessel).get()
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
        let bc = self.basicController as! RLM_BasicController

        let vesselRes1 = try! bc.realm.get().objects(RLM_ReminderVessel.self)
        let reminderRes1 = try! bc.realm.get().objects(RLM_Reminder.self)
        let performRes1 = try! bc.realm.get().objects(RLM_ReminderPerform.self)

        XCTAssertEqual(vesselRes1.count, 1)
        XCTAssertEqual(reminderRes1.count, 2)
        XCTAssertEqual(performRes1.count, 1)

        try! self.basicController.delete(vessel: vessel).get()

        let vesselRes2 = try! bc.realm.get().objects(RLM_ReminderVessel.self)
        let reminderRes2 = try! bc.realm.get().objects(RLM_Reminder.self)
        let performRes2 = try! bc.realm.get().objects(RLM_ReminderPerform.self)

        XCTAssertEqual(vesselRes2.count, 0)
        XCTAssertEqual(reminderRes2.count, 0)
        XCTAssertEqual(performRes2.count, 0)
    }

    func test_reminder_cascadingDeletes() {
        let vessel = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        let reminder = try! self.basicController.newReminder(for: vessel).get()
        try! self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
        let bc = self.basicController as! RLM_BasicController

        let vesselRes1 = try! bc.realm.get().objects(RLM_ReminderVessel.self)
        let reminderRes1 = try! bc.realm.get().objects(RLM_Reminder.self)
        let performRes1 = try! bc.realm.get().objects(RLM_ReminderPerform.self)

        XCTAssertEqual(vesselRes1.count, 1)
        XCTAssertEqual(reminderRes1.count, 2)
        XCTAssertEqual(performRes1.count, 1)

        try! self.basicController.delete(reminder: reminder).get()

        let vesselRes2 = try! bc.realm.get().objects(RLM_ReminderVessel.self)
        let reminderRes2 = try! bc.realm.get().objects(RLM_Reminder.self)
        let performRes2 = try! bc.realm.get().objects(RLM_ReminderPerform.self)

        XCTAssertEqual(vesselRes2.count, 1)
        XCTAssertEqual(reminderRes2.count, 1)
        XCTAssertEqual(performRes2.count, 0)
    }

    func test_delete_last_reminder() {
        let exp = self.expectation(description: "")
        exp.expectedFulfillmentCount = 1
        _ = try! self.basicController.newReminderVessel(displayName: nil, icon: nil).get()
        self.token = try! self.basicController.enabledReminders(sorted: .nextPerformDate, ascending: true).get().observe
        { change in
            exp.fulfill()
            switch change {
            case .initial(let data):
                XCTAssertEqual(data.count, 1)
                let result = self.basicController.delete(reminder: data[0]!)
                switch result {
                case .success:
                    XCTFail()
                case .failure(let error):
                    XCTAssertEqual(error, .unableToDeleteLastReminder)
                    XCTAssertEqual(data.count, 1)
                }
            case .update, .error:
                XCTFail()
            }
        }
        self.wait(for: [exp], timeout: 0.3)
    }
}

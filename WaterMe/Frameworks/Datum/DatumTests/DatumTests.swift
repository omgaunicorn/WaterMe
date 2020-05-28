//
//  DatumTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/04/26.
//  Copyright © 2020 Jeffrey Bergier. All rights reserved.
//

import XCTest
@testable import Datum

class DatumTestsBase: XCTestCase {
    
    class func newBasicController() -> BasicController {
//        fatalError("Subclass to provide Realm or CD Basic Controller for testing")
        return try! testing_NewRLMBasicController(of: .local).get()
    }
    
    private(set) var basicController: BasicController!
    internal var token: ObservationToken!

    override func setUpWithError() throws {
        self.basicController = type(of: self).newBasicController()
        for x in 0..<2 {
            let num = x*100
            let vessel = try self.basicController.newReminderVessel(
                displayName: "x\(num)番花",
                icon: .emoji("🤬"),
                reminders: nil
            ).get()
            for y in 0..<3 {
                let reminder = try self.basicController.newReminder(for: vessel).get()
                try self.basicController.update(
                    kind: .water,
                    interval: 2,
                    note: "Vessel: \(vessel.displayName!): Reminder: \(y*100)",
                    in: reminder
                ).get()
                for _ in 0..<10 {
                    try self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
                }
            }
        }
    }

    override func tearDownWithError() throws {
        // Delete Core Data and Realm Store
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try fm.removeItem(at: appSupport)
    }
    
    func test123() {
        let query = try! self.basicController.groupedReminders().get()
        let wait = XCTestExpectation()
        self.token = query.observe { changes in
            switch changes {
            case .initial(let reminders):
                for section in 0..<reminders.numberOfSections {
                    let count = reminders.count(at: .init(row: 0, section: section))!
                    switch section {
                    case 0:
                        XCTAssertEqual(count, 2)
                    case 1,2,4:
                        XCTAssertEqual(count, 0)
                    case 3:
                        XCTAssertEqual(count, 6)
                    default:
                        XCTFail()
                    }
                }
                wait.fulfill()
            case .update:
                XCTFail()
            case .error(let error):
                XCTFail(error.localizedDescription)
            }
        }
        self.wait(for: [wait], timeout: 0.1)
    }

}

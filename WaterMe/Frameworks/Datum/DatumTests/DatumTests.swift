//
//  DatumTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/04/26.
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

class DatumTestsBase: XCTestCase {
    
    func newBasicController() -> BasicController {
        fatalError("Subclass to provide Realm or CD Basic Controller for testing")
    }
    
    private(set) var basicController: BasicController!
    internal var token: ObservationToken!

    override func setUpWithError() throws {
        self.basicController = self.newBasicController()
    }
    
    func setUpSmall() throws {
        for x in 1...2 {
            let num = x*100
            let vessel = try self.basicController.newReminderVessel(
                displayName: "\(num)番花",
                icon: .emoji("🤬")
            ).get()
            for y in 1...3 {
                let reminder = try self.basicController.newReminder(for: vessel).get()
                try self.basicController.update(
                    kind: .water,
                    interval: 2,
                    note: "Vessel: \(vessel.displayName!): Reminder: \(y*100)",
                    in: reminder
                ).get()
                for _ in 1...10 {
                    try self.basicController.appendNewPerformToReminders(with: [.init(rawValue: reminder.uuid)]).get()
                }
            }
        }
    }

    override func tearDownWithError() throws {
        self.token?.invalidate()
        self.token = nil
    }
    
    /*
    func test_basicController() {
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
    }*/

}

extension CollectionQuery {
    func test_observe_loadData(_ closure: @escaping (AnyCollection<Element, Index>) -> Void) -> ObservationToken {
        return self.observe() { change in
            switch change {
            case .initial(let data):
                closure(data)
            case .update:
                XCTFail()
            case .error:
                XCTFail()
            }
        }
    }
    
    func test_observe_receiveUpdates(_ closure: @escaping ((AnyCollection<Element, Index>, CollectionChangeUpdate<Index>)) -> Void) -> ObservationToken {
        var data: AnyCollection<Element, Index>!
        return self.observe() { change in
            switch change {
            case .initial(let _data):
                data = _data
            case .update(let updates):
                closure((data, updates))
            case .error:
                XCTFail()
            }
        }
    }
}

//
//  VesselShareTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2020/08/01.
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

class CD_VesselShareTests: DatumTestsBase {

    override func newBasicController() -> BasicController {
        return try! testing_NewCDBasicController().get()
    }

    var context: NSManagedObjectContext {
        return (self.basicController as! CD_BasicController).container.viewContext
    }

    func test_oneSharePresent_init() {
        let request = CD_VesselShare.request
        let context = self.context
        let results = try! context.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first!.vessels.count, 0)
    }

    func test_oneSharePresent_createTwoVessels() {
        var sharedReference: CD_VesselShare!
        _ = {
            let request = CD_VesselShare.request
            let context = self.context
            let results = try! context.fetch(request)
            XCTAssertEqual(results.count, 1)
            sharedReference = results.first!
            XCTAssertEqual(sharedReference.vessels.count, 0)
        }()

        _ = try! self.basicController.newReminderVessel(displayName: "One", icon: nil).get()
        _ = try! self.basicController.newReminderVessel(displayName: "Two", icon: nil).get()

        _ = {
            let request = CD_VesselShare.request
            let context = self.context
            let results = try! context.fetch(request)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first!.vessels.count, 2)
            XCTAssertEqual(sharedReference.vessels.count, 2)
        }()

        _ = {
            let one = sharedReference.vessels.filter({ ($0 as! CD_ReminderVessel).displayName == "One" })
            let two = sharedReference.vessels.filter({ ($0 as! CD_ReminderVessel).displayName == "Two" })
            XCTAssertEqual(one.count, 1)
            XCTAssertEqual(two.count, 1)
        }()
    }

    func test_oneSharePresent_deleteTwoVessels() {

        let one = try! self.basicController.newReminderVessel(displayName: "One", icon: nil).get()
        let two = try! self.basicController.newReminderVessel(displayName: "Two", icon: nil).get()

        _ = {
            let request = CD_VesselShare.request
            let context = self.context
            let results = try! context.fetch(request)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first!.vessels.count, 2)
        }()

        try! self.basicController.delete(vessel: one).get()
        try! self.basicController.delete(vessel: two).get()

        _ = {
            let request = CD_VesselShare.request
            let context = self.context
            let results = try! context.fetch(request)
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first!.vessels.count, 0)
        }()
    }

    func test_cascadeDelete() {

        _ = try! self.basicController.newReminderVessel(displayName: "One", icon: nil).get()
        _ = try! self.basicController.newReminderVessel(displayName: "Two", icon: nil).get()

        let shareRequest = CD_VesselShare.request
        let vesselRequest = CD_ReminderVessel.request
        var share: CD_VesselShare!
        let context = self.context

        _ = {
            let results = try! context.fetch(shareRequest)
            XCTAssertEqual(results.count, 1)
            share = results.first!
            XCTAssertEqual(share.vessels.count, 2)
        }()

        context.delete(share)
        try! context.save()

        _ = {
            let results = try! context.fetch(shareRequest)
            XCTAssertEqual(results.count, 0)
        }

        _ = {
            let results = try! context.fetch(vesselRequest)
            XCTAssertEqual(results.count, 0)
        }
    }

}

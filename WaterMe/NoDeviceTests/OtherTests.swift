//
//  OtherTests.swift
//  NoDeviceTests
//
//  Created by Jeffrey Bergier on 7/2/18.
//  Copyright © 2018 Saturday Apps.
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

@testable import WaterMe
import Foundation
import XCTest

class OtherTests: XCTestCase {

    func testSubstringSearchingOneMatch() {
        let primary = "one two three" as NSString
        let searchString = "two"
        let ranges = primary.ranges(of: searchString)

        XCTAssert(ranges.count == 1)
        let range = ranges.first!
        XCTAssert(range.location == 4)
        XCTAssert(range.length == 3)
        XCTAssert(NSMaxRange(range) == 7)
    }

    func testSubstringSearchingTwoSeparateMatches() {
        let primary = "one two three two" as NSString
        let searchString = "two"
        let ranges = primary.ranges(of: searchString)

        XCTAssert(ranges.count == 2)
        let range1 = ranges[0]
        XCTAssert(range1.location == 4)
        XCTAssert(range1.length == 3)
        XCTAssert(NSMaxRange(range1) == 7)

        let range2 = ranges[1]
        XCTAssert(range2.location == 14)
        XCTAssert(range2.length == 3)
        XCTAssert(NSMaxRange(range2) == 17)
    }

    func testSubstringSearchingTwoTouchingMatches() {
        let primary = "one twotwo three" as NSString
        let searchString = "two"
        let ranges = primary.ranges(of: searchString)

        XCTAssert(ranges.count == 2)
        let range1 = ranges[0]
        XCTAssert(range1.location == 4)
        XCTAssert(range1.length == 3)
        XCTAssert(NSMaxRange(range1) == 7)

        let range2 = ranges[1]
        XCTAssert(range2.location == 7)
        XCTAssert(range2.length == 3)
        XCTAssert(NSMaxRange(range2) == 10)
    }

    func testSubstringSearchingNoMatches() {
        let primary = "one three four five" as NSString
        let searchString = "two"
        let ranges = primary.ranges(of: searchString)

        XCTAssert(ranges.count == 0)
    }
}

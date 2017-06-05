//
//  ImageProcessingTests.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/4/17.
//  Copyright © 2017 Saturday Apps.
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

@testable import WaterMeData
import XCTest

class ImageProcessingTests: XCTestCase {
    
    func testCropSize() {
        let max: CGFloat = 500
        
        let squareTooBig = CGSize(width: 1000, height: 1000).squareSize(withMaxEdge: max)
        XCTAssert(squareTooBig.width == max)
        XCTAssert(squareTooBig.height == max)
        
        let squareTooSmall = CGSize(width: 200, height: 200).squareSize(withMaxEdge: max)
        XCTAssert(squareTooSmall.width == 200)
        XCTAssert(squareTooSmall.height == 200)
        
        let tall = CGSize(width: 300, height: 800).squareSize(withMaxEdge: max)
        XCTAssert(tall.width == 300)
        XCTAssert(tall.height == 300)
        
        let wide = CGSize(width: 900, height: 350).squareSize(withMaxEdge: max)
        XCTAssert(wide.width == 350)
        XCTAssert(wide.height == 350)
        
        let equal = CGSize(width: max, height: max).squareSize(withMaxEdge: max)
        XCTAssert(equal.width == max)
        XCTAssert(equal.height == max)
    }
    
}

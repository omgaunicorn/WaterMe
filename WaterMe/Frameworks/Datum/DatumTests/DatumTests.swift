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

    override func setUpWithError() throws {
        self.basicController = type(of: self).newBasicController()
    }

    override func tearDownWithError() throws {
        
    }
    
    func test123() {
        print("test")
    }

}

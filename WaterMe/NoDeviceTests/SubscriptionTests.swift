//
//  NoDeviceTests.swift
//  NoDeviceTests
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import StoreKit
@testable import WaterMeStore
import XCTest

class SubscriptionTests: XCTestCase {
    
    fileprivate struct FakeSKProduct: SKProductProtocol {
        var productIdentifier: String
        var localizedTitle: String
        var localizedDescription: String
        var price: NSDecimalNumber
        var priceLocale: Locale
    }
    
    func testSubscriptionConversion() {
        let fakePro = FakeSKProduct(productIdentifier: PrivateKeys.kSubscriptionProMonthly,
                                    localizedTitle: "PRO-BRO",
                                    localizedDescription: "THIS-FOR-PROS",
                                    price: NSDecimalNumber(value: 1000.99),
                                    priceLocale: Locale(identifier: "en-US"))
        let fakeBasic = FakeSKProduct(productIdentifier: PrivateKeys.kSubscriptionBasicMonthly,
                                    localizedTitle: "BASIC-BRP",
                                    localizedDescription: "BASIC-ONLY",
                                    price: NSDecimalNumber(value: 10.99),
                                    priceLocale: Locale(identifier: "en-US"))
        
        let output = UnpurchasedSubscription.subscriptions(from: [fakePro, fakeBasic])
        let oFakePro = output[0]
        XCTAssert(oFakePro.level == .pro)
        XCTAssert(oFakePro.localizedDescription == "THIS-FOR-PROS")
        XCTAssert(oFakePro.localizedTitle == "PRO-BRO")
        XCTAssert(oFakePro.period == .month)
        XCTAssert(oFakePro.price == 1000.99)
        XCTAssert(oFakePro.priceLocale.identifier == "en-US")
        let oFakeBasic = output[1]
        XCTAssert(oFakeBasic.level == .basic)
        XCTAssert(oFakeBasic.localizedDescription == "BASIC-ONLY")
        XCTAssert(oFakeBasic.localizedTitle == "BASIC-BRP")
        XCTAssert(oFakeBasic.period == .month)
        XCTAssert(oFakeBasic.price == 10.99)
        XCTAssert(oFakeBasic.priceLocale.identifier == "en-US")
        XCTAssert(output.count == 2)
    }
    
    func testValidLevelInit() {
        let proMonth = Level(productID: PrivateKeys.kSubscriptionProMonthly)
        let proYear = Level(productID: PrivateKeys.kSubscriptionProYearly)
        let basicMonth = Level(productID: PrivateKeys.kSubscriptionBasicMonthly)
        let basicYear = Level(productID: PrivateKeys.kSubscriptionBasicYearly)
        
        XCTAssert(proMonth != nil)
        XCTAssert(proYear != nil)
        XCTAssert(basicMonth != nil)
        XCTAssert(basicYear != nil)

        XCTAssert(proMonth == .pro)
        XCTAssert(proYear == .pro)
        XCTAssert(basicMonth == .basic)
        XCTAssert(basicYear == .basic)
    }
    
    func testInvalidLevelInit() {
        let wrong = Level(productID: "GARBAGE DATA")
        XCTAssert(wrong == nil)
    }
    
    func testValidPeriodInit() {
        let proMonth = Period(productID: PrivateKeys.kSubscriptionProMonthly)
        let proYear = Period(productID: PrivateKeys.kSubscriptionProYearly)
        let basicMonth = Period(productID: PrivateKeys.kSubscriptionBasicMonthly)
        let basicYear = Period(productID: PrivateKeys.kSubscriptionBasicYearly)
        
        XCTAssert(proMonth != nil)
        XCTAssert(proYear != nil)
        XCTAssert(basicMonth != nil)
        XCTAssert(basicYear != nil)
        
        XCTAssert(proMonth! == .month)
        XCTAssert(proYear! == .year)
        XCTAssert(basicMonth! == .month)
        XCTAssert(basicYear! == .year)
    }
    
    func testInvalidPeriodInit() {
        let wrong = Period(productID: "GARBAGE DATA")
        XCTAssert(wrong == nil)
    }
}

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
        
        let output = Subscription.subscriptions(from: [fakePro, fakeBasic])
        XCTAssert(output.count == 3)
    }
    
    func testNILLevelInit() {
        let freeLevel = Subscription.Level(productIdentifier: nil)
        XCTAssert(freeLevel != nil)
        switch freeLevel! {
        case .free:
            XCTAssert(true)
        default:
            XCTAssert(false, "Init with NIL should have returned a free subscription level. Not: \(freeLevel!)")
        }
    }
    
    func testValidLevelInit() {
        let proMonth = Subscription.Level(productIdentifier: PrivateKeys.kSubscriptionProMonthly)
        let proYear = Subscription.Level(productIdentifier: PrivateKeys.kSubscriptionProYearly)
        let basicMonth = Subscription.Level(productIdentifier: PrivateKeys.kSubscriptionBasicMonthly)
        let basicYear = Subscription.Level(productIdentifier: PrivateKeys.kSubscriptionBasicYearly)
        
        XCTAssert(proMonth != nil)
        XCTAssert(proYear != nil)
        XCTAssert(basicMonth != nil)
        XCTAssert(basicYear != nil)

        if case .pro(let id) = proMonth! {
            XCTAssert(id == PrivateKeys.kSubscriptionProMonthly)
        } else {
            XCTAssert(false)
        }
        
        if case .pro(let id) = proYear! {
            XCTAssert(id == PrivateKeys.kSubscriptionProYearly)
        } else {
            XCTAssert(false)
        }
        
        if case .basic(let id) = basicMonth! {
            XCTAssert(id == PrivateKeys.kSubscriptionBasicMonthly)
        } else {
            XCTAssert(false)
        }
        
        if case .basic(let id) = basicYear! {
            XCTAssert(id == PrivateKeys.kSubscriptionBasicYearly)
        } else {
            XCTAssert(false)
        }
    }
    
    func testInvalidLevelInit() {
        let wrong = Subscription.Level(productIdentifier: "GARBAGE DATA")
        XCTAssert(wrong == nil)
    }
    
}

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
        XCTAssert(output.count == 3)
    }
    
    func testNILLevelInit() {
        let freeLevel = Level(productIdentifier: nil)
        XCTAssert(freeLevel != nil)
        switch freeLevel! {
        case .free:
            XCTAssert(true)
        default:
            XCTAssert(false, "Init with NIL should have returned a free subscription level. Not: \(freeLevel!)")
        }
    }
    
    func testValidLevelInit() {
        let proMonth = Level(productIdentifier: PrivateKeys.kSubscriptionProMonthly)
        let proYear = Level(productIdentifier: PrivateKeys.kSubscriptionProYearly)
        let basicMonth = Level(productIdentifier: PrivateKeys.kSubscriptionBasicMonthly)
        let basicYear = Level(productIdentifier: PrivateKeys.kSubscriptionBasicYearly)
        
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
        let wrong = Level(productIdentifier: "GARBAGE DATA")
        XCTAssert(wrong == nil)
    }
    
    func testValidPeriodInit() {
        let proMonth = Period(productIdentifier: PrivateKeys.kSubscriptionProMonthly)
        let proYear = Period(productIdentifier: PrivateKeys.kSubscriptionProYearly)
        let basicMonth = Period(productIdentifier: PrivateKeys.kSubscriptionBasicMonthly)
        let basicYear = Period(productIdentifier: PrivateKeys.kSubscriptionBasicYearly)
        
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
        let wrong = Period(productIdentifier: "GARBAGE DATA")
        XCTAssert(wrong == nil)
    }
    
    func testPriceEquality() {
        let free1 = Price.free
        let free2 = Price.free
        let paid1 = Price.paid(price: 1.0, locale: Locale(identifier: "en-US"))
        let paid2 = Price.paid(price: 1.0, locale: Locale(identifier: "ru-RU"))
        let paid3 = Price.paid(price: 2.0, locale: Locale(identifier: "es-ES"))
        let paid4 = Price.paid(price: 3.0, locale: Locale(identifier: "en-UK"))
        
        XCTAssert(free1 == free1)
        XCTAssert(free1 == free2)
        XCTAssert(free1 != paid1)
        XCTAssert(free1 != paid2)
        XCTAssert(free1 != paid3)
        XCTAssert(free1 != paid4)
        
        XCTAssert(free2 == free1)
        XCTAssert(free2 == free2)
        XCTAssert(free2 != paid1)
        XCTAssert(free2 != paid2)
        XCTAssert(free2 != paid3)
        XCTAssert(free2 != paid4)
        
        XCTAssert(paid1 != free1)
        XCTAssert(paid1 != free2)
        XCTAssert(paid1 == paid1)
        XCTAssert(paid1 == paid2)
        XCTAssert(paid1 != paid3)
        XCTAssert(paid1 != paid4)
        
        XCTAssert(paid2 != free1)
        XCTAssert(paid2 != free2)
        XCTAssert(paid2 == paid1)
        XCTAssert(paid2 == paid2)
        XCTAssert(paid2 != paid3)
        XCTAssert(paid2 != paid4)
        
        XCTAssert(paid3 != free1)
        XCTAssert(paid3 != free2)
        XCTAssert(paid3 != paid1)
        XCTAssert(paid3 != paid2)
        XCTAssert(paid3 == paid3)
        XCTAssert(paid3 != paid4)
        
        XCTAssert(paid4 != free1)
        XCTAssert(paid4 != free2)
        XCTAssert(paid4 != paid1)
        XCTAssert(paid4 != paid2)
        XCTAssert(paid4 != paid3)
        XCTAssert(paid4 == paid4)
    }
    
    func testPriceComparability() {
        
        let free1 = Price.free
        let free2 = Price.free
        let paid1 = Price.paid(price: 1.0, locale: Locale(identifier: "en-US"))
        let paid2 = Price.paid(price: 1.0, locale: Locale(identifier: "ru-RU"))
        let paid3 = Price.paid(price: 2.0, locale: Locale(identifier: "es-ES"))
        let paid4 = Price.paid(price: 3.0, locale: Locale(identifier: "en-UK"))
        
        XCTAssertFalse(free1 > free1)
        XCTAssertFalse(free1 > free2)
        XCTAssertFalse(free1 > paid1)
        XCTAssertFalse(free1 > paid2)
        XCTAssertFalse(free1 > paid3)
        XCTAssertFalse(free1 > paid4)
        
        XCTAssert(free1 >= free1)
        XCTAssert(free1 >= free2)
        XCTAssertFalse(free1 >= paid1)
        XCTAssertFalse(free1 >= paid2)
        XCTAssertFalse(free1 >= paid3)
        XCTAssertFalse(free1 >= paid4)
        
        XCTAssertFalse(free1 < free1)
        XCTAssertFalse(free1 < free2)
        XCTAssert(free1 < paid1)
        XCTAssert(free1 < paid2)
        XCTAssert(free1 < paid3)
        XCTAssert(free1 < paid4)
        
        XCTAssert(free1 <= free1)
        XCTAssert(free1 <= free2)
        XCTAssert(free1 <= paid1)
        XCTAssert(free1 <= paid2)
        XCTAssert(free1 <= paid3)
        XCTAssert(free1 <= paid4)
        
        XCTAssertFalse(free2 < free1)
        XCTAssertFalse(free2 < free2)
        XCTAssert(free2 < paid1)
        XCTAssert(free2 < paid2)
        XCTAssert(free2 < paid3)
        XCTAssert(free2 < paid4)
        
        XCTAssert(free2 <= free1)
        XCTAssert(free2 <= free2)
        XCTAssert(free2 <= paid1)
        XCTAssert(free2 <= paid2)
        XCTAssert(free2 <= paid3)
        XCTAssert(free2 <= paid4)
        
        XCTAssertFalse(free2 > free1)
        XCTAssertFalse(free2 > free2)
        XCTAssertFalse(free2 > paid1)
        XCTAssertFalse(free2 > paid2)
        XCTAssertFalse(free2 > paid3)
        XCTAssertFalse(free2 > paid4)
        
        XCTAssert(free2 >= free1)
        XCTAssert(free2 >= free2)
        XCTAssertFalse(free2 >= paid1)
        XCTAssertFalse(free2 >= paid2)
        XCTAssertFalse(free2 >= paid3)
        XCTAssertFalse(free2 >= paid4)
        
        XCTAssertFalse(paid1 < free1)
        XCTAssertFalse(paid1 < free2)
        XCTAssertFalse(paid1 < paid1)
        XCTAssertFalse(paid1 < paid2)
        XCTAssert(paid1 < paid3)
        XCTAssert(paid1 < paid4)
        
        XCTAssertFalse(paid1 <= free1)
        XCTAssertFalse(paid1 <= free2)
        XCTAssert(paid1 <= paid1)
        XCTAssert(paid1 <= paid2)
        XCTAssert(paid1 <= paid3)
        XCTAssert(paid1 <= paid4)
        
        XCTAssert(paid1 > free1)
        XCTAssert(paid1 > free2)
        XCTAssertFalse(paid1 > paid1)
        XCTAssertFalse(paid1 > paid2)
        XCTAssertFalse(paid1 > paid3)
        XCTAssertFalse(paid1 > paid4)
        
        XCTAssert(paid1 >= free1)
        XCTAssert(paid1 >= free2)
        XCTAssert(paid1 >= paid1)
        XCTAssert(paid1 >= paid2)
        XCTAssertFalse(paid1 >= paid3)
        XCTAssertFalse(paid1 >= paid4)
        
        XCTAssertFalse(paid2 < free1)
        XCTAssertFalse(paid2 < free2)
        XCTAssertFalse(paid2 < paid1)
        XCTAssertFalse(paid2 < paid2)
        XCTAssert(paid2 < paid3)
        XCTAssert(paid2 < paid4)
        
        XCTAssertFalse(paid2 <= free1)
        XCTAssertFalse(paid2 <= free2)
        XCTAssert(paid2 <= paid1)
        XCTAssert(paid2 <= paid2)
        XCTAssert(paid2 <= paid3)
        XCTAssert(paid2 <= paid4)
        
        XCTAssert(paid2 > free1)
        XCTAssert(paid2 > free2)
        XCTAssertFalse(paid2 > paid1)
        XCTAssertFalse(paid2 > paid2)
        XCTAssertFalse(paid2 > paid3)
        XCTAssertFalse(paid2 > paid4)
        
        XCTAssert(paid2 >= free1)
        XCTAssert(paid2 >= free2)
        XCTAssert(paid2 >= paid1)
        XCTAssert(paid2 >= paid2)
        XCTAssertFalse(paid2 >= paid3)
        XCTAssertFalse(paid2 >= paid4)
        
        XCTAssertFalse(paid3 < free1)
        XCTAssertFalse(paid3 < free2)
        XCTAssertFalse(paid3 < paid1)
        XCTAssertFalse(paid3 < paid2)
        XCTAssertFalse(paid3 < paid3)
        XCTAssert(paid3 < paid4)
        
        XCTAssertFalse(paid3 <= free1)
        XCTAssertFalse(paid3 <= free2)
        XCTAssertFalse(paid3 <= paid1)
        XCTAssertFalse(paid3 <= paid2)
        XCTAssert(paid3 <= paid3)
        XCTAssert(paid3 <= paid4)
        
        XCTAssert(paid3 > free1)
        XCTAssert(paid3 > free2)
        XCTAssert(paid3 > paid1)
        XCTAssert(paid3 > paid2)
        XCTAssertFalse(paid3 > paid3)
        XCTAssertFalse(paid3 > paid4)
        
        XCTAssert(paid3 >= free1)
        XCTAssert(paid3 >= free2)
        XCTAssert(paid3 >= paid1)
        XCTAssert(paid3 >= paid2)
        XCTAssert(paid3 >= paid3)
        XCTAssertFalse(paid3 >= paid4)
        
        XCTAssertFalse(paid4 < free1)
        XCTAssertFalse(paid4 < free2)
        XCTAssertFalse(paid4 < paid1)
        XCTAssertFalse(paid4 < paid2)
        XCTAssertFalse(paid4 < paid3)
        XCTAssertFalse(paid4 < paid4)
        
        XCTAssertFalse(paid4 <= free1)
        XCTAssertFalse(paid4 <= free2)
        XCTAssertFalse(paid4 <= paid1)
        XCTAssertFalse(paid4 <= paid2)
        XCTAssertFalse(paid4 <= paid3)
        XCTAssert(paid4 <= paid4)
        
        XCTAssert(paid4 > free1)
        XCTAssert(paid4 > free2)
        XCTAssert(paid4 > paid1)
        XCTAssert(paid4 > paid2)
        XCTAssert(paid4 > paid3)
        XCTAssertFalse(paid4 > paid4)
        
        XCTAssert(paid4 >= free1)
        XCTAssert(paid4 >= free2)
        XCTAssert(paid4 >= paid1)
        XCTAssert(paid4 >= paid2)
        XCTAssert(paid4 >= paid3)
        XCTAssert(paid4 >= paid4)
    }
    
}

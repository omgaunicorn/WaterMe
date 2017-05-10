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
        let fakePro = FakeSKProduct(productIdentifier: PrivateKeys.kProSubscriptionProductKey,
                                    localizedTitle: "PRO-BRO",
                                    localizedDescription: "THIS-FOR-PROS",
                                    price: NSDecimalNumber(value: 1000.99),
                                    priceLocale: Locale(identifier: "en-US"))
        let fakeBasic = FakeSKProduct(productIdentifier: PrivateKeys.kBasicSubscriptionProductKey,
                                    localizedTitle: "BASIC-BRP",
                                    localizedDescription: "BASIC-ONLY",
                                    price: NSDecimalNumber(value: 10.99),
                                    priceLocale: Locale(identifier: "en-US"))
        
        let output = Subscription.subscriptions(from: [fakePro, fakeBasic])
        XCTAssert(output.count == 3)
    }
    
}

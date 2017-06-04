//
//  SubscriptionConversion.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/9/17.
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

import StoreKit

internal protocol SKProductProtocol {
    var productIdentifier: String { get }
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var price: NSDecimalNumber { get }
    var priceLocale: Locale { get }
}

extension SKProduct: SKProductProtocol {}

internal extension UnpurchasedSubscription {
    internal static func subscriptions(from products: [SKProductProtocol]) -> [UnpurchasedSubscription] {
        let subscriptions = products.flatMap() { product -> UnpurchasedSubscription? in
            return UnpurchasedSubscription(product: product)
        }
        return subscriptions
    }
    internal init?(product: SKProductProtocol) {
        guard
            let level = Level(productID: product.productIdentifier),
            let period = Period(productID: product.productIdentifier)
        else { return nil }
        self.period = period
        self.level = level
        self.localizedTitle = product.localizedTitle
        self.localizedDescription = product.localizedDescription
        self.price = product.price.doubleValue
        self.priceLocale = product.priceLocale
        self.product = product
    }
}

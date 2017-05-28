//
//  SubscriptionConversion.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/9/17.
//
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

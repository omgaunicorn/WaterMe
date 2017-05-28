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
        return subscriptions + [UnpurchasedSubscription.free()]
    }
    internal init?(product: SKProductProtocol) {
        guard let level = UnpurchasedSubscription.Level(productIdentifier: product.productIdentifier),
            let period = UnpurchasedSubscription.Period(productIdentifier: product.productIdentifier) else { return nil }
        self.period = period
        self.level = level
        self.localizedTitle = product.localizedTitle
        self.localizedDescription = product.localizedDescription
        self.price = .paid(price: product.price.doubleValue, locale: product.priceLocale)
        self.product = product as? SKProduct
    }
}

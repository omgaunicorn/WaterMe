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

internal extension Subscription {
    internal static func subscriptions(from products: [SKProductProtocol]) -> [Subscription] {
        let subscriptions = products.flatMap() { product -> Subscription? in
            return Subscription(product: product)
        }
        return subscriptions + [Subscription.free()]
    }
}

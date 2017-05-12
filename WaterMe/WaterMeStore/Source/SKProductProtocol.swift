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

public extension Subscription.Level {
    public init?(productIdentifier: String?) {
        guard let id = productIdentifier else { self = .free; return; }
        switch id {
        case PrivateKeys.kSubscriptionBasicMonthly, PrivateKeys.kSubscriptionBasicYearly:
            self = .basic(productIdentifier: id)
        case PrivateKeys.kSubscriptionProYearly, PrivateKeys.kSubscriptionProMonthly:
            self = .pro(productIdentifier: id)
        default:
            return nil
        }
    }
}

internal extension Subscription.Period {
    internal init?(productIdentifier: String) {
        if productIdentifier.contains("monthly") {
            self = .month
        } else if productIdentifier.contains("yearly") {
            self = .year
        } else {
            return nil
        }
    }
}

internal extension Subscription {
    internal init?(product: SKProductProtocol) {
        guard let level = Subscription.Level(productIdentifier: product.productIdentifier),
            let period = Subscription.Period(productIdentifier: product.productIdentifier) else { return nil }
        self.period = period
        self.level = level
        self.localizedTitle = product.localizedTitle
        self.localizedDescription = product.localizedDescription
        self.price = .paid(price: product.price.doubleValue, locale: product.priceLocale)
    }
}

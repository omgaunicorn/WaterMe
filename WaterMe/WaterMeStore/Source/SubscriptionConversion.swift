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
            let level: Subscription.Level
            switch product.productIdentifier {
            case PrivateKeys.kBasicSubscriptionProductKey:
                level = .basic
            case PrivateKeys.kProSubscriptionProductKey:
                level = .pro
            default:
                assert(false, "Invalid ProductID Found: \(product.productIdentifier)")
                return nil
            }
            let subscription = Subscription(level: level,
                                            localizedTitle: product.localizedTitle,
                                            localizedDescription: product.localizedDescription,
                                            price: .paid(price: product.price.doubleValue, locale: product.priceLocale))
            return subscription
        }
        return subscriptions + [Subscription.free()]
    }
}

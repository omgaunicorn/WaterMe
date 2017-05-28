//
//  SubscriptionLevel.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import StoreKit

public struct UnpurchasedSubscription {
    public var period: Period
    public var level: Level
    public var localizedTitle: String
    public var localizedDescription: String
    public var price: Price
    internal var product: SKProduct?
}

public protocol HasSubscriptionType {
    var subscription: UnpurchasedSubscription! { get set }
}

public extension HasSubscriptionType {
    public mutating func configure(with subscription: UnpurchasedSubscription) {
        self.subscription = subscription
    }
}

public extension UnpurchasedSubscription {
    public static func free() -> UnpurchasedSubscription {
        return UnpurchasedSubscription(
            period: .none,
            level: .free,
            localizedTitle: "WaterMe Free",
            localizedDescription: "🌺  Unlimited number of plants\n🔔  Unlimited number of reminders",
            price: .free,
            product: nil)
    }
}

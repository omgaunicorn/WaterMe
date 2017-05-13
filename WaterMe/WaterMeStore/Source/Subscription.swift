//
//  SubscriptionLevel.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import StoreKit

public struct Subscription {
    
    public enum Level {
        case free, basic(productIdentifier: String), pro(productIdentifier: String)
    }
    
    public enum Price {
        case free, paid(price: Double, locale: Locale)
    }
    
    public enum Period {
        case month, year, none
    }
    
    public var period: Period
    public var level: Level
    public var localizedTitle: String
    public var localizedDescription: String
    public var price: Price
    internal var product: SKProduct?
}

public protocol HasSubscriptionType {
    var subscription: Subscription! { get set }
}

public extension HasSubscriptionType {
    public mutating func configure(with subscription: Subscription) {
        self.subscription = subscription
    }
}

extension Subscription.Price: Comparable {
    
    public static func == (lhs: Subscription.Price, rhs: Subscription.Price) -> Bool {
        switch lhs {
        case .free:
            guard case .free = rhs else { return false }
            return true
        case .paid(let lhsPrice, _):
            guard case .paid(let rhsPrice, _) = rhs else { return false }
            return lhsPrice == rhsPrice
        }
    }
    
    public static func < (lhs: Subscription.Price, rhs:Subscription.Price) -> Bool {
        return lhs.doubleValue < rhs.doubleValue
    }
    
    private var doubleValue: Double {
        switch self {
        case .free:
            return 0
        case .paid(let price, _):
            return price
        }
    }
}

public extension Subscription {
    public static func free() -> Subscription {
        return Subscription(
            period: .none,
            level: .free,
            localizedTitle: "WaterMe Free",
            localizedDescription: "🌺  Unlimited number of plants\n🔔  Unlimited number of reminders",
            price: .free,
            product: nil)
    }
}

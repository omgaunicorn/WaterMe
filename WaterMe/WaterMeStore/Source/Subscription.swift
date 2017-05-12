//
//  SubscriptionLevel.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import Foundation

public struct Subscription {
    
    public enum Level {
        case free, basic(productIdentifier: String), pro(productIdentifier: String)
    }
    
    public enum Price {
        case free, paid(price: Double, locale: Locale)
    }
    
    public var level: Subscription.Level
    public var localizedTitle: String
    public var localizedDescription: String
    public var price: Price
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

internal extension Subscription {
    internal init?(product: SKProductProtocol) {
        guard let level = Subscription.Level(productIdentifier: product.productIdentifier) else { return nil }
        self.level = level
        self.localizedTitle = product.localizedTitle
        self.localizedDescription = product.localizedDescription
        self.price = .paid(price: product.price.doubleValue, locale: product.priceLocale)
    }
}

public extension Subscription {
    public static func free() -> Subscription {
        return Subscription(level: .free,
                     localizedTitle: "Free",
                     localizedDescription: "• Unlimited number of plants\n• Unlimited number of reminders",
                     price: .free)
    }
}

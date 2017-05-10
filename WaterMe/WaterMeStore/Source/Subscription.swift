//
//  SubscriptionLevel.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import Foundation

public struct Subscription {
    
    public enum Level: String {
        case free, basic, pro
    }
    
    public enum Price {
        case free, paid(price: Double, locale: Locale)
    }
    
    public var level: Subscription.Level
    public var localizedTitle: String
    public var localizedDescription: String
    public var price: Price
    
}

public extension Subscription {
    public static func free() -> Subscription {
        return Subscription(level: .free,
                     localizedTitle: "Free",
                     localizedDescription: "• Unlimited number of plants\n• Unlimited number of reminders",
                     price: .free)
    }
}

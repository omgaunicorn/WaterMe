//
//  SubscriptionLevel.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import Foundation

struct Subscription {
    
    enum Level: String {
        case free, basic, pro
    }
    
    enum Price {
        case free, paid(price: Double, locale: Locale)
    }
    
    var level: Subscription.Level
    var localizedTitle: String
    var localizedDescription: String
    var price: Price
    
}

extension Subscription {
    static func free() -> Subscription {
        return Subscription(level: .free,
                     localizedTitle: "Free",
                     localizedDescription: "• Unlimited number of plants\n• Unlimited number of reminders",
                     price: .free)
    }
}

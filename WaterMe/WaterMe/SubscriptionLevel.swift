//
//  SubscriptionLevel.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//


enum SubscriptionLevel: String {
    case free, basic, pro
}

extension SubscriptionLevel {
    var localizedTitle: String {
        switch self {
        case .free:
            return "Free"
        case .basic:
            return "Basic"
        case .pro:
            return "Pro"
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .free:
            return "• Unlimited number of plants\n• Unlimited number of reminders"
        case .basic:
            return "• Cloud Backup & Multi-device Sync\n• Unlimited number of plants\n• Unlimited number of reminders"
        case .pro:
            return "• Photo tracking over time\n• Cloud Backup & Multi-device Sync\n• Unlimited number of plants\n• Unlimited number of reminders"
        }
    }
    
    var localizedCallToAction: String {
        switch self {
        case .free:
            return "Choose Free"
        case .basic:
            return "Subscribe to Basic"
        case .pro:
            return "Go Professional!"
        }
    }
}



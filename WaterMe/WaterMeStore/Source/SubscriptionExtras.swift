//
//  SubscriptionExtras.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/27/17.
//
//

public enum Level {
    case basic, pro
}

public enum Period {
    case month, year
}

public extension Level {
    public init?(productID: String) {
        switch productID {
        case PrivateKeys.kSubscriptionBasicMonthly, PrivateKeys.kSubscriptionBasicYearly:
            self = .basic
        case PrivateKeys.kSubscriptionProYearly, PrivateKeys.kSubscriptionProMonthly:
            self = .pro
        default:
            return nil
        }
    }
}

internal extension Period {
    internal init?(productID: String) {
        if productID.contains("monthly") {
            self = .month
        } else if productID.contains("yearly") {
            self = .year
        } else {
            return nil
        }
    }
}

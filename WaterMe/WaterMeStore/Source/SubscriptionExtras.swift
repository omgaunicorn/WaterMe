//
//  SubscriptionExtras.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/27/17.
//
//

public enum Level {
    case free, basic(productIdentifier: String), pro(productIdentifier: String)
}

public enum Price {
    case free, paid(price: Double, locale: Locale)
}

public enum Period {
    case month, year, none
}

extension Level: Comparable {
    public static func == (lhs: Level, rhs: Level) -> Bool {
        switch lhs {
        case .free:
            guard case .free = rhs else { return false }
            return true
        case .basic(let lhsPID):
            guard case .basic(let rhsPID) = rhs else { return false }
            return lhsPID == rhsPID
        case .pro(let lhsPID):
            guard case .pro(let rhsPID) = rhs else { return false }
            return lhsPID == rhsPID
        }
    }
    public static func < (lhs: Level, rhs:Level) -> Bool {
        switch rhs {
        case .free:
            return false
        case .basic:
            switch lhs {
            case .free:
                return true
            case .basic, .pro:
                return false
            }
        case .pro:
            return true
        }
    }
}

public extension Level {
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
    public var rawValue: String {
        switch self {
        case .free:
            return "free"
        case .basic(productIdentifier: let pID), .pro(productIdentifier: let pID):
            return pID
        }
    }
}

extension Price: Comparable {
    public static func == (lhs: Price, rhs: Price) -> Bool {
        switch lhs {
        case .free:
            guard case .free = rhs else { return false }
            return true
        case .paid(let lhsPrice, _):
            guard case .paid(let rhsPrice, _) = rhs else { return false }
            return lhsPrice == rhsPrice
        }
    }
    public static func < (lhs: Price, rhs: Price) -> Bool {
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

internal extension Period {
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

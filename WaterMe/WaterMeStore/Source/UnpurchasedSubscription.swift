//
//  SubscriptionLevel.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import Foundation

public struct UnpurchasedSubscription {
    public var period: Period
    public var level: Level
    public var localizedTitle: String
    public var localizedDescription: String
    public var price: Double
    public var priceLocale: Locale
    internal var product: SKProductProtocol
}

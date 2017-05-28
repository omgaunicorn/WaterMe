//
//  PurchasedSubscription.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/27/17.
//
//

import Foundation

public struct PurchasedSubscription {
    public var period: Period
    public var level: Level
    public var productID: String
    public var purchaseDate: Date
    public var expirationDate: Date
    
    public init?(productID: String, purchaseDate: Date, expirationDate: Date) {
        guard
            let level = Level(productIdentifier: productID),
            let period = Period(productIdentifier: productID)
        else { return nil }
        self.period = period
        self.level = level
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
    }
}

//
//  PurchasedSubscription.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/27/17.
//
//

import Foundation

public struct PurchasedSubscription {
    public private(set) var period: Period
    public private(set) var level: Level
    public var productID: String {
        didSet {
            self.period = Period(productID: self.productID)!
            self.level = Level(productID: self.productID)!
        }
    }
    public var purchaseDate: Date
    public var expirationDate: Date
    
    public init?(productID: String, purchaseDate: Date, expirationDate: Date) {
        guard
            let level = Level(productID: productID),
            let period = Period(productID: productID)
        else { return nil }
        self.period = period
        self.level = level
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
    }
}

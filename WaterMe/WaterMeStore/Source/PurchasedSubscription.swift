//
//  PurchasedSubscription.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/27/17.
//  Copyright © 2017 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
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

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
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public struct PurchasedSubscription {
    let period: Period
    let level: Level
    let productID: String
    let purchaseDate: Date
    let expirationDate: Date
    
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

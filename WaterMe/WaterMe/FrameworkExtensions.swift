//
//  FrameworkExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/9/17.
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

import WaterMeStore
import WaterMeData
import UIKit

extension Sequence {
    func first<T>(of type: T.Type? = nil) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        let indexPaths = self.indexPathsForSelectedItems
        indexPaths?.forEach({ self.deselectItem(at: $0, animated: animated) })
    }
}

extension Receipt {
    var serverPurchasedSubscription: PurchasedSubscription? {
        guard let pID = self.server_productID, let exp = self.server_expirationDate, let pur = self.server_purchaseDate else { return nil }
        return PurchasedSubscription(productID: pID, purchaseDate: pur, expirationDate: exp)
    }
    
    var clientPurchasedSubscription: PurchasedSubscription? {
        guard let pID = self.client_productID, let exp = self.client_expirationDate, let pur = self.client_purchaseDate else { return nil }
        return PurchasedSubscription(productID: pID, purchaseDate: pur, expirationDate: exp)
    }
}

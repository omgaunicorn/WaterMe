//
//  ReceiptWatcher.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/29/17.
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

import TPInAppReceipt
import RealmSwift
import WaterMeData
import WaterMeStore
import Foundation

class ReceiptWatcher {
    
    enum Result {
        case both(server: PurchasedSubscription, local: PurchasedSubscription), local(PurchasedSubscription), none
    }
    
    private var receiptController: ReceiptController?
    
    var currentSubscription: Result {
        let receipt = self.receiptController?.receipt
        let serverPurchase = receipt?.serverPurchasedSubscription
        let localPurchase = type(of: self).parseReceiptFromDisk()?.1
        if let localPurchase = localPurchase, let serverPurchase = serverPurchase {
            return .both(server: serverPurchase, local: localPurchase)
        } else if let localPurchase = localPurchase {
            return .local(localPurchase)
        } else {
            return .none
        }
    }
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.configureReceiptControllerIfNeeded()
            self.updateRealmReceiptIfNeeded()
        }.fire()
    }
    
    private func configureReceiptControllerIfNeeded() {
        guard
            self.receiptController == nil,
            let user = SyncUser.current
        else { return }
        self.receiptController = ReceiptController(user: user)
        self.receiptController?.receiptChanged = { [weak self] newReceipt, _ in
            self?.updateRealmReceiptIfNeeded()
        }
    }
    
    func updateRealmReceiptIfNeeded() {
        guard
            let controller = self.receiptController,
            controller.receipt.client_lastVerifyDate.timeIntervalSinceNow < -280,
            let (data, sub) = type(of: self).parseReceiptFromDisk()
        else { return }
        controller.updateReceipt(pkcs7Data: data, productID: sub.productID, purchaseDate: sub.purchaseDate, expirationDate: sub.expirationDate)
    }
    
    func updateRealmReceipIfPossible() {
        guard
            let controller = self.receiptController,
            let (data, sub) = type(of: self).parseReceiptFromDisk()
        else { return }
        controller.updateReceipt(pkcs7Data: data, productID: sub.productID, purchaseDate: sub.purchaseDate, expirationDate: sub.expirationDate)
    }
    
    class func parseReceiptFromDisk() -> (Data, PurchasedSubscription)? {
        guard
            let data = try? InAppReceiptManager.shared.receiptData(),
            let receipt = try? InAppReceiptManager.shared.receipt(),
            let newest = receipt.purchases.sorted(by: { $0.0.subscriptionExpirationDate >= $0.1.subscriptionExpirationDate }).first,
            let sub = PurchasedSubscription(productID: newest.productIdentifier, purchaseDate: newest.purchaseDate, expirationDate: newest.subscriptionExpirationDate)
        else { return nil }
        return (data, sub)
    }
}

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
    
    private var receiptController: ReceiptController?
    var currentSubscription: PurchasedSubscription? {
        guard let controller = self.receiptController else { return nil }
        let receipt = controller.receipt
        var serverPurchase: PurchasedSubscription?
        if let pID = receipt.server_productID, let exp = receipt.server_expirationDate, let pur = receipt.server_purchaseDate {
            serverPurchase = PurchasedSubscription(productID: pID, purchaseDate: pur, expirationDate: exp)
        }
        var clientPurchase: PurchasedSubscription?
        if let pID = receipt.client_productID, let exp = receipt.client_expirationDate, let pur = receipt.client_purchaseDate {
            clientPurchase = PurchasedSubscription(productID: pID, purchaseDate: pur, expirationDate: exp)
        }
        if let clientPurchase = clientPurchase, let serverPurchase = serverPurchase {
            // if both subscriptions exist, return the one with the longest expiration date
            if serverPurchase.expirationDate > clientPurchase.expirationDate {
                return serverPurchase
            } else {
                return clientPurchase
            }
        } else if let clientPurchase = clientPurchase {
            // if only the client exists, return the client
            return clientPurchase
        } else if let serverPurchase = serverPurchase {
            // if only the server exists, return the server
            return serverPurchase
        } else {
            // if neither exist, return NIL
            return nil
        }
    }
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
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
    
    private func updateRealmReceiptIfNeeded() {
        guard
            let controller = self.receiptController,
            controller.receipt.client_lastVerifyDate.timeIntervalSinceNow < -60,
            let (data, sub) = self.parseReceiptFromDisk()
        else { return }
        controller.updateReceipt(pkcs7Data: data, productID: sub.productID, purchaseDate: sub.purchaseDate, expirationDate: sub.expirationDate)
    }
    
    private func parseReceiptFromDisk() -> (Data, PurchasedSubscription)? {
        guard
            let data = try? InAppReceiptManager.shared.receiptData(),
            let receipt = try? InAppReceiptManager.shared.receipt(),
            let newest = receipt.purchases.sorted(by: { $0.0.subscriptionExpirationDate >= $0.1.subscriptionExpirationDate }).first,
            let sub = PurchasedSubscription(productID: newest.productIdentifier, purchaseDate: newest.purchaseDate, expirationDate: newest.subscriptionExpirationDate)
        else { return nil }
        return (data, sub)
    }
}

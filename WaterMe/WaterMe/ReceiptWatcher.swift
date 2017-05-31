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

import Result
import TPInAppReceipt
import RealmSwift
import WaterMeData
import WaterMeStore
import Foundation

class ReceiptWatcher {
    
    enum ReceiptSource {
        case both(server: PurchasedSubscription, local: PurchasedSubscription), local(PurchasedSubscription)
    }
    
    enum ReceiptError: Error {
        case noReceiptData, noReceiptObject, noSubscriptionFound
    }
    
    private var receiptController: ReceiptController?
    
    var currentSubscription: Result<ReceiptSource, ReceiptError> {
        let receipt = self.receiptController?.receipt
        let localResult = type(of: self).parseReceiptFromDisk()
        switch localResult {
        case .success(_, let localPurchase):
            if let serverPurchase = receipt?.serverPurchasedSubscription {
                return .success(.both(server: serverPurchase, local: localPurchase))
            } else {
                return .success(.local(localPurchase))
            }
        case .failure(let error):
            return .failure(error)
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
            let (data, sub) = type(of: self).parseReceiptFromDisk().value
        else { return }
        controller.updateReceipt(pkcs7Data: data, productID: sub.productID, purchaseDate: sub.purchaseDate, expirationDate: sub.expirationDate)
    }
    
    func updateRealmReceipIfPossible() {
        guard
            let controller = self.receiptController,
            let (data, sub) = type(of: self).parseReceiptFromDisk().value
        else { return }
        controller.updateReceipt(pkcs7Data: data, productID: sub.productID, purchaseDate: sub.purchaseDate, expirationDate: sub.expirationDate)
    }
    
    class func parseReceiptFromDisk() -> Result<(Data, PurchasedSubscription), ReceiptError> {
        guard let data = try? InAppReceiptManager.shared.receiptData() else { return .failure(.noReceiptData) }
        guard let receipt = try? InAppReceiptManager.shared.receipt() else { return .failure(.noReceiptObject) }
        let filtered = receipt.purchases.filter() {
            $0.productIdentifier == WaterMeStore.PrivateKeys.kSubscriptionBasicMonthly ||
            $0.productIdentifier == WaterMeStore.PrivateKeys.kSubscriptionBasicYearly ||
            $0.productIdentifier == WaterMeStore.PrivateKeys.kSubscriptionProMonthly ||
            $0.productIdentifier == WaterMeStore.PrivateKeys.kSubscriptionProYearly
        }
        let sorted = filtered.sorted(by: { $0.0.subscriptionExpirationDate >= $0.1.subscriptionExpirationDate })
        guard
            let newest = sorted.first,
            let sub = PurchasedSubscription(productID: newest.productIdentifier,
                                            purchaseDate: newest.purchaseDate,
                                            expirationDate: newest.subscriptionExpirationDate)
        else { return .failure(.noSubscriptionFound) }
        return .success(data, sub)
    }
}

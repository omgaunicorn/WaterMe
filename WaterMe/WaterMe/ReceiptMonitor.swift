//
//  ReceiptMonitor.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/18/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import TPInAppReceipt
import StoreKit

class ReceiptMonitor: NSObject, SKPaymentTransactionObserver {
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        self.updateReceipt()
    }
    
    private(set) var purchased: (level: Level, expirationDate: Date)?
    private(set) var receiptData: Data?
    private(set) var receiptChanged: Bool = false
    
    func updateReceipt() {
        if let newReceipt = type(of: self).parseReceipt() {
            self.receiptData = newReceipt.receiptData
            self.purchased = (newReceipt.level, newReceipt.expirationDate)
        } else {
            self.receiptData = nil
            self.purchased = nil
        }
        self.receiptChanged = false
    }
    
    private func needsToUpdateReceipt() -> Bool {
        guard let newReceipt = type(of: self).parseReceipt() else { return false }
        guard let oldReceipt = self.purchased else { return true }
        let comparison = type(of: self).compare(oldReceipt: oldReceipt, newReceipt: (newReceipt.level, newReceipt.expirationDate))
        return comparison
    }
    
    private static func compare(oldReceipt: (level: Level, expirationDate: Date), newReceipt: (level: Level, expirationDate: Date)) -> Bool {
        // make sure the levels match
        guard oldReceipt.level == newReceipt.level else { return false }
        // then compare expirationDates as the last straw
        return oldReceipt.expirationDate == newReceipt.expirationDate
    }
    
    private class func parseReceipt() -> (receiptData: Data, level: Level, expirationDate: Date)? {
        guard let data = try? InAppReceiptManager.shared.receiptData() else { return nil }
        let receipt = try? InAppReceiptManager.shared.receipt()
        
        let date = Date()
        let basicMonthly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionBasicMonthly, forDate: date)
        let basicYearly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionBasicYearly, forDate: date)
        let proMonthly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionProMonthly, forDate: date)
        let proYearly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionProYearly, forDate: date)
        
        let level: Level
        let expirationDate: Date
        if let purchase = proYearly, let _level = Level(productID: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else if let purchase = proMonthly, let _level = Level(productID: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else if let purchase = basicYearly, let _level = Level(productID: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else if let purchase = basicMonthly, let _level = Level(productID: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else {
            return nil
        }
        return (receiptData: data, level: level, expirationDate: expirationDate)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        self.receiptChanged = self.needsToUpdateReceipt()
        log.debug("Transactions Changed. Needs to Update Receipt: \(self.receiptChanged)")
    }
}

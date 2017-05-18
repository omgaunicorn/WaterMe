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
    
    private(set) var purchased: (level: Subscription.Level, expirationDate: Date) = (.free, Date())
    private(set) var receiptData: Data?
    private(set) var receiptChanged: Bool = false
    
    func updateReceipt() {
        let newReceipt = type(of: self).parseReceipt()
        self.receiptData = newReceipt.receiptData
        self.purchased = (newReceipt.level, newReceipt.expirationDate)
        self.receiptChanged = false
    }
    
    private func needsToUpdateReceipt() -> Bool {
        let newReceipt = type(of: self).parseReceipt()
        let comparison = type(of: self).compare(oldReceipt: self.purchased, newReceipt: (newReceipt.level, newReceipt.expirationDate))
        return comparison
    }
    
    private static func compare(oldReceipt: (level: Subscription.Level, expirationDate: Date), newReceipt: (level: Subscription.Level, expirationDate: Date)) -> Bool {
        // make sure the levels match
        guard oldReceipt.level == newReceipt.level else { return false }
        // make sure we don't compare dates if the level is free since those dates aren't real
        guard newReceipt.level != .free else { return true }
        // then compare expirationDates as the last straw
        return oldReceipt.expirationDate == newReceipt.expirationDate
    }
    
    private class func parseReceipt() -> (receiptData: Data?, level: Subscription.Level, expirationDate: Date) {
        let data = try? InAppReceiptManager.shared.receiptData()
        let receipt = try? InAppReceiptManager.shared.receipt()
        
        let date = Date()
        let basicMonthly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionBasicMonthly, forDate: date)
        let basicYearly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionBasicYearly, forDate: date)
        let proMonthly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionProMonthly, forDate: date)
        let proYearly = receipt?.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: PrivateKeys.kSubscriptionProYearly, forDate: date)
        
        let level: Subscription.Level
        let expirationDate: Date
        if let purchase = proYearly, let _level = Subscription.Level(productIdentifier: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else if let purchase = proMonthly, let _level = Subscription.Level(productIdentifier: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else if let purchase = basicYearly, let _level = Subscription.Level(productIdentifier: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else if let purchase = basicMonthly, let _level = Subscription.Level(productIdentifier: purchase.productIdentifier) {
            level = _level
            expirationDate = purchase.subscriptionExpirationDate
        } else {
            level = .free
            expirationDate = date
        }
        return (receiptData: data, level: level, expirationDate: expirationDate)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        self.receiptChanged = self.needsToUpdateReceipt()
        log.debug("Transactions Changed. Needs to Update Receipt: \(self.receiptChanged)")
    }
}

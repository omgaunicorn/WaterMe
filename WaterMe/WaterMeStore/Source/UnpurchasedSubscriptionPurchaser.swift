//
//  SubscriptionPurchaser.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/12/17.
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

import XCGLogger
import StoreKit

public protocol UnpurchasedSubscriptionPurchaseType: Resettable {
    var subscription: UnpurchasedSubscription { get }
    init?(itemToPurchase: UnpurchasedSubscription)
    @discardableResult func start(completionHandler: @escaping (PurchaseResult) -> Void) -> Bool
}

public protocol HasUnpurchasedSubscriptionPurchaseType {
    var subscriptionPurchaser: UnpurchasedSubscriptionPurchaseType! { get set }
}

public extension HasUnpurchasedSubscriptionPurchaseType {
    public mutating func configure(with subscriptionPurchaser: UnpurchasedSubscriptionPurchaseType?) {
        if let subscriptionPurchaser = subscriptionPurchaser {
            self.subscriptionPurchaser = subscriptionPurchaser
        }
    }
}

public enum PurchaseResult {
    case failed(Error, UnpurchasedSubscription), deferred(UnpurchasedSubscription), success(UnpurchasedSubscription)
}

public class UnpurchasedSubscriptionPurchaser: NSObject, UnpurchasedSubscriptionPurchaseType, SKPaymentTransactionObserver {
    
    public let subscription: UnpurchasedSubscription
    
    private let productToPurchase: SKProduct
    private var completionHandler: ((PurchaseResult) -> Void)? // if nil we have not started yet
    
    public required init(itemToPurchase: UnpurchasedSubscription) {
        self.productToPurchase = itemToPurchase.product as! SKProduct
        self.subscription = itemToPurchase
        super.init()
        SKPaymentQueue.default().add(self) // add queue now to allow unwanted transactions to flow through. hacky, but needed for now
    }
    
    public func start(completionHandler: @escaping (PurchaseResult) -> Void) -> Bool {
        guard self.completionHandler == nil else { return false }
        log.debug("Starting Purchase: \(self.productToPurchase.productIdentifier)")
        self.completionHandler = completionHandler
        let queue = SKPaymentQueue.default()
        let payment = SKPayment(product: self.productToPurchase)
        queue.add(self)
        queue.add(payment)
        return true
    }
    
    public func reset() {
        SKPaymentQueue.default().remove(self)
        self.completionHandler = nil
        log.debug("Finished Purchase: \(self.productToPurchase.productIdentifier)")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard
            let completionHandler = self.completionHandler,
            let transaction = transactions.filter({ $0.payment.productIdentifier == self.productToPurchase.productIdentifier }).last
        else {
            log.warning("Unexpected Transaction Seen: \(transactions)")
            log.severe("Finishing Unknown Transactions. Do not ship this!")
            transactions.forEach({ queue.finishTransaction($0) })
            return
        }
        switch transaction.transactionState {
        case .purchasing:
            log.debug("Purchasing: \(transaction.payment.productIdentifier)")
        case .deferred:
            log.debug("Deferred: \(transaction.payment.productIdentifier)")
            self.reset()
            completionHandler(.deferred(self.subscription))
        case .purchased, .restored:
            log.debug("Purchased / Restored: \(transaction.payment.productIdentifier)")
            queue.finishTransaction(transaction)
            self.reset()
            completionHandler(.success(self.subscription))
        case .failed:
            let error = transaction.error!
            log.debug("Failed: \(transaction.payment.productIdentifier) - Error: \(error)")
            queue.finishTransaction(transaction)
            self.reset()
            completionHandler(.failed(error, self.subscription))
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

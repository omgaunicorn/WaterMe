//
//  SubscriptionPurchaser.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/12/17.
//
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
    
    public required init?(itemToPurchase: UnpurchasedSubscription) {
        guard let productToPurchase = itemToPurchase.product else { return nil }
        self.productToPurchase = productToPurchase
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

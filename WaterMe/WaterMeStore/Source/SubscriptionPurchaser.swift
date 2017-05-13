//
//  SubscriptionPurchaser.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/12/17.
//
//

import StoreKit

public protocol SubscriptionPurchaseType: Resettable {
    var subscription: Subscription { get }
    init?(itemToPurchase: Subscription)
    @discardableResult func start(completionHandler: @escaping (PurchaseResult) -> Void) -> Bool
}

public protocol HasSubscriptionPurchaseType {
    var subscriptionPurchaser: SubscriptionPurchaseType! { get set }
}

public extension HasSubscriptionPurchaseType {
    public mutating func configure(with subscriptionPurchaser: SubscriptionPurchaseType?) {
        if let subscriptionPurchaser = subscriptionPurchaser {
            self.subscriptionPurchaser = subscriptionPurchaser
        }
    }
}

public enum PurchaseResult {
    case failed(Error, Subscription), deferred(Subscription), success(Subscription)
}

public class SubscriptionPurchaser: NSObject, SubscriptionPurchaseType, SKPaymentTransactionObserver {
    
    public let subscription: Subscription
    
    private let productToPurchase: SKProduct
    private var completionHandler: ((PurchaseResult) -> Void)? // if nil we have not started yet
    
    public required init?(itemToPurchase: Subscription) {
        guard let productToPurchase = itemToPurchase.product else { return nil }
        self.productToPurchase = productToPurchase
        self.subscription = itemToPurchase
        super.init()
        SKPaymentQueue.default().add(self) // add queue now to allow unwanted transactions to flow through. hacky, but needed for now
    }
    
    public func start(completionHandler: @escaping (PurchaseResult) -> Void) -> Bool {
        guard self.completionHandler == nil else { return false }
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
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard
            let completionHandler = self.completionHandler,
            let transaction = transactions.filter({ $0.payment.productIdentifier == self.productToPurchase.productIdentifier }).last
        else {
            NSLog("Warning: \(#function): Unexpected Transaction Seen.")
            return
        }
        switch transaction.transactionState {
        case .purchasing:
            print("...purchasing...")
        case .deferred:
            self.reset()
            completionHandler(.deferred(self.subscription))
        case .purchased, .restored:
            queue.finishTransaction(transaction)
            self.reset()
            completionHandler(.success(self.subscription))
        case .failed:
            queue.finishTransaction(transaction)
            self.reset()
            completionHandler(.failed(transaction.error!, self.subscription))
        }
    }
    
    deinit {
    }
}

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
    private var completionHandler: ((PurchaseResult) -> Void)?
    
    public required init?(itemToPurchase: Subscription) {
        guard let productToPurchase = itemToPurchase.product else { return nil }
        self.productToPurchase = productToPurchase
        self.subscription = itemToPurchase
        super.init()
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
        guard let transaction = transactions.filter({ $0.payment.productIdentifier == self.productToPurchase.productIdentifier }).last else { return }
        switch transaction.transactionState {
        case .purchasing:
            break
        case .deferred:
            self.completionHandler?(.deferred(self.subscription))
            self.reset()
        case .purchased, .restored:
            queue.finishTransaction(transaction)
            self.completionHandler?(.success(self.subscription))
            self.reset()
        case .failed:
            queue.finishTransaction(transaction)
            self.completionHandler?(.failed(transaction.error!, self.subscription))
            self.reset()
        }
    }
}

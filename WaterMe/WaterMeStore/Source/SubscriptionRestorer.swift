//
//  SubscriptionRestorer.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/13/17.
//
//

import Result
import StoreKit

public typealias SubscriptionRestoreResult = Result<Void, AnyError>

public protocol SubscriptionRestoreType: Resettable {
    @discardableResult func start(completionHandler: @escaping (SubscriptionRestoreResult) -> Void) -> Bool
}

public protocol HasSubscriptionRestoreType {
    var subscriptionRestorer: SubscriptionRestoreType { get set }
}

public extension HasSubscriptionRestoreType {
    public mutating func configure(with subscriptionRestorer: SubscriptionRestoreType?) {
        if let subscriptionRestorer = subscriptionRestorer {
            self.subscriptionRestorer = subscriptionRestorer
        }
    }
}

public class SubscriptionRestorer: NSObject, SubscriptionRestoreType, SKPaymentTransactionObserver {
    
    private var completionHandler: ((SubscriptionRestoreResult) -> Void)?
    
    public override init() {
        super.init()
        SKPaymentQueue.default().add(self) // add queue now to allow unwanted transactions to flow through. hacky, but needed for now
    }
    
    public func start(completionHandler: @escaping (SubscriptionRestoreResult) -> Void) -> Bool {
        guard self.completionHandler == nil else { return false }
        log.debug("Started restoring purchases")
        self.completionHandler = completionHandler
        let queue = SKPaymentQueue.default()
        queue.add(self)
        queue.restoreCompletedTransactions()
        return true
    }

    public func reset() {
        SKPaymentQueue.default().remove(self)
        self.completionHandler = nil
        log.debug("Finished restoring purchases")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        guard let completionHandler = self.completionHandler else {
            log.warning("Saw unexpected update: \(error)")
            return
        }
        self.reset()
        completionHandler(.failure(AnyError(error)))
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        guard let completionHandler = self.completionHandler else {
            log.warning("Saw unexpected update")
            return
        }
        self.reset()
        completionHandler(.success())
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard self.completionHandler != nil else {
            log.warning("Saw unexpected transactions: \(transactions)")
            return
        }
        transactions.forEach({ queue.finishTransaction($0) })
    }
}

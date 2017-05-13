//
//  PaymentQueueObserver.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/12/17.
//
//

import StoreKit

public protocol BootTransactionObserverType {
    var transactionActivitySinceBoot: Bool { get }
}

public class BootTransactionObserver: NSObject, BootTransactionObserverType, SKPaymentTransactionObserver {
    
    public var transactionActivitySinceBoot = false
    
    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        self.transactionActivitySinceBoot = true
    }
    
}

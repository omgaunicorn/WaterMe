//
//  SubscriptionRestorer.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/13/17.
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
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
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
        completionHandler(.success(()))
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard self.completionHandler != nil else {
            log.warning("Saw unexpected transactions: \(transactions)")
            return
        }
        transactions.forEach({ queue.finishTransaction($0) })
    }
}

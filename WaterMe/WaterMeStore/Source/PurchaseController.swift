//
//  PurchaseController.swift
//  WaterMeStore
//
//  Created by Jeffrey Bergier on 13/1/18.
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

public class PurchaseController {

    private let purchaser = Purchaser()

    public var transactionsInFlightUpdated: (() -> Void)?
    private var transactionsInFlight: [SKPaymentTransaction] = []

    public init?() {
        guard SKPaymentQueue.canMakePayments() else { return nil }
        self.purchaser.transactionsUpdated = { [unowned self] transaction in
            self.transactionsInFlight += [transaction]
            self.transactionsInFlightUpdated?()
        }
    }

    public func nextTransactionForPresentingToUser() -> SKPaymentTransaction? {
        return self.transactionsInFlight.popLast()
    }

    public func buy(product: SKProduct) {
        self.purchaser.buy(product: product)
    }

    public func finish(transaction: SKPaymentTransaction) {
        self.purchaser.finish(transaction: transaction)
    }

    public func fetchTipJarProducts(completion: @escaping (TipJarProducts?) -> Void) {
        let requester = TipJarProductRequester()
        requester.fetchTipJarProducts() { result in
            _ = requester // capture the requester here so its not released and deallocated mid-flight
            completion(result)
        }
    }
}

internal class Purchaser: NSObject, SKPaymentTransactionObserver {

    internal var transactionsUpdated: ((SKPaymentTransaction) -> Void)?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    internal func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    internal func finish(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.filter({ trans -> Bool in
            switch trans.transactionState {
            case .deferred, .purchasing:
                return false
            case .failed:
                let error = SKError.Code(rawValue: (trans.error! as NSError).code)
                switch error {
                case .paymentCancelled?:
                    self.finish(transaction: trans)
                    return false
                default:
                    return true
                }
            case .purchased, .restored:
                return true
            }
        }).forEach({ self.transactionsUpdated?($0) })
    }
}

/*
 typedef NS_ENUM(NSInteger,SKErrorCode) {
 SKErrorUnknown,
 SKErrorClientInvalid,                                                     // client is not allowed to issue the request, etc.
 SKErrorPaymentCancelled,                                                  // user cancelled the request, etc.
 SKErrorPaymentInvalid,                                                    // purchase identifier was invalid, etc.
 SKErrorPaymentNotAllowed,                                                 // this device is not allowed to make the payment
 SKErrorStoreProductNotAvailable,                                          // Product is not available in the current storefront
 SKErrorCloudServicePermissionDenied NS_ENUM_AVAILABLE_IOS(9_3),           // user has not allowed access to cloud service information
 SKErrorCloudServiceNetworkConnectionFailed NS_ENUM_AVAILABLE_IOS(9_3),    // the device could not connect to the nework
 SKErrorCloudServiceRevoked NS_ENUM_AVAILABLE_IOS(10_3),                   // user has revoked permission to use this cloud service
 };
 */

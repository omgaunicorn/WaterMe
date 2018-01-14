//
//  InFlightTransaction.swift
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

import StoreKit

// Transactions have too many states
// This code is designed to reduce the number of possible states the UI has to deal with
// Also, the parsing sorts the transactions into ones that can be ignored (.purchasing, .deferred)
// And the ones that need to be finished now with no user interaction (.paymentCancelled)

public struct InFlightTransaction {

    public let state: State
    public let transaction: SKPaymentTransaction

    public enum State {
        case success, cancelled, errorNetwork, errorNotAllowed, errorUnknown
    }

    public static func process(transactions: [SKPaymentTransaction])
        -> (inFlight: [InFlightTransaction], ignored: [SKPaymentTransaction], readyToBeFinished: [SKPaymentTransaction])
    {
        var inFlight = [InFlightTransaction]()
        var ignored = [SKPaymentTransaction]()
        var readyToBeFinished = [SKPaymentTransaction]()
        var transactions = transactions
        for _ in 0 ..< transactions.count {
            let transaction = transactions.popLast()!
            switch transaction.transactionState {
            case .deferred, .purchasing:
                ignored += [transaction]
            case .purchased, .restored:
                inFlight += [InFlightTransaction(state: .success, transaction: transaction)]
            case .failed:
                let error = SKError.Code(rawValue: (transaction.error! as NSError).code) ?? .unknown
                switch error {
                case .paymentCancelled:
                    // needs the UI to update but should also be auto-completed
                    inFlight += [InFlightTransaction(state: .cancelled, transaction: transaction)]
                    readyToBeFinished += [transaction]
                case .clientInvalid, .cloudServicePermissionDenied, .cloudServiceRevoked, .paymentInvalid, .storeProductNotAvailable, .unknown:
                    inFlight += [InFlightTransaction(state: .errorUnknown, transaction: transaction)]
                case .cloudServiceNetworkConnectionFailed:
                    inFlight += [InFlightTransaction(state: .errorNetwork, transaction: transaction)]
                case .paymentNotAllowed:
                    inFlight += [InFlightTransaction(state: .errorNotAllowed, transaction: transaction)]
                }
            }
        }
        return (inFlight: inFlight, ignored: ignored, readyToBeFinished: readyToBeFinished)
    }
}

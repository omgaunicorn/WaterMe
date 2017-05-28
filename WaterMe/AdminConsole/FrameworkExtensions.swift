//
//  FrameworkExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//


extension Sequence {
    func first<T>(of type: T.Type? = nil) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

enum ReceiptWatcherError: Int, Error {
    
    case noUserLoggedIn = 100001, receiptControllerConfiguredIncorrectly, receiptVerifiedRecently, noNSDataFoundForReceipt, requestJSONParseError, responseJSONParseError, urlResponseNotHTTPResponse, unexpectedServerResponseCode, noDataReceivedFromResponse, responseJSONDidNotContainReceiptData, responseJSONPurchasesContainedUnexpectedData
    
    var localizedDescription: String {
        switch self {
        case .noUserLoggedIn:
            return "Can't Watch Receipts. No User Logged In."
        case .receiptControllerConfiguredIncorrectly:
            return "The Receipt Controller is not configured correctly. It is missing an override UUID path."
        case .receiptVerifiedRecently:
            return "This receipt has been verified recently. No need to check again right now."
        case .noNSDataFoundForReceipt:
            return "No PKCS7 Data Found for Receipt."
        case .requestJSONParseError:
            return "Error processing JSON to upload to Apple Receipt Verification Servers"
        case .responseJSONParseError:
            return "Error processing JSON downloaded from Apple Receipt Verification Servers"
        case .urlResponseNotHTTPResponse:
            return "The Respons from the network request was not an HTTPResponse"
        case .unexpectedServerResponseCode:
            return "Apple Verification Server responded with unexpected response code."
        case .noDataReceivedFromResponse:
            return "The response from Apple Verification Servers contained no data."
        case .responseJSONDidNotContainReceiptData:
            return "JSON Object did not contain 'receipt.in_app' purchase array."
        case .responseJSONPurchasesContainedUnexpectedData:
            return "The array of purchases received from Apple contained unexpected data. It couldn't all be converted to PurchasedSubscription objects."
        }
    }
}

//
//  FrameworkExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
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

struct LocalizedError: Error {
    
    var receiptWatcherError: ReceiptWatcherError?
    var adminRealmControllerError: AdminRealmControllerError?
    
    var localizedDescription: String {
        return receiptWatcherError?.localizedDescription ?? adminRealmControllerError?.localizedDescription ?? "UNKNOWN ERROR"
    }
    
    init(rawValue: Int) {
        self.receiptWatcherError = ReceiptWatcherError(rawValue: rawValue)
        self.adminRealmControllerError = AdminRealmControllerError(rawValue: rawValue)
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

enum AdminRealmControllerError: Int, Error {
    
    case jsonErrorDecodingFileList = 300001, noFilesFoundInFileListJSON, invalidUserNameFoundInFileListJSON, invalidFileFoundInRealmFolderOfFileListJSON, unexpectedResponseFileListJSON, invalidSharedSecretInResponseFileListJSON, adminUserLoginError
    
    var localizedDescription: String {
        switch self {
        case .jsonErrorDecodingFileList:
            return "FileSizeList response could not be converted into JSON Objects"
        case .noFilesFoundInFileListJSON:
            return "No Realm files were found in the FileSizeList JSON."
        case .invalidUserNameFoundInFileListJSON:
            return "An invalid username was found in the FileSizeList JSON"
        case .invalidFileFoundInRealmFolderOfFileListJSON:
            return "An invalid file was found in the folder that contains Realm files."
        case .unexpectedResponseFileListJSON:
            return "Received an unexpected response while downloading the FileSizeList."
        case .invalidSharedSecretInResponseFileListJSON:
            return "INVALID SHARED SECRET FROM FILELISTJSON SERVER. SOMETHING MASSIVE IS WRONG."
        case .adminUserLoginError:
            return "Failed to login as the Admin user for the ROS"
        }
    }
}

//
//  Receipt.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/18/17.
//
//

import RealmSwift

public class Receipt: Object {
    
    internal(set) public dynamic var pkcs7Data: Data?
    
    internal(set) public dynamic var server_lastVerifyDate = Date()
    internal(set) public dynamic var server_appleStatusCode: Int = -1
    internal(set) public dynamic var server_productID: String?
    internal(set) public dynamic var server_purchaseDate: Date?
    internal(set) public dynamic var server_expirationDate: Date?
    
    fileprivate(set) public dynamic var client_originalCreationDate = Date()
    internal(set) public dynamic var client_productID: String?
    internal(set) public dynamic var client_purchaseDate: Date?
    internal(set) public dynamic var client_expirationDate: Date?
    
}

public extension Receipt {
    public class func __admin_console_only_newReceiptByCopyingReceipt(_ receipt: Receipt) -> Receipt {
        let newReceipt = Receipt()
        newReceipt.pkcs7Data = receipt.pkcs7Data
        newReceipt.server_lastVerifyDate = receipt.server_lastVerifyDate
        newReceipt.server_appleStatusCode = receipt.server_appleStatusCode
        newReceipt.server_productID = receipt.server_productID
        newReceipt.server_purchaseDate = receipt.server_purchaseDate
        newReceipt.server_expirationDate = receipt.server_expirationDate
        newReceipt.client_originalCreationDate = receipt.client_originalCreationDate
        newReceipt.client_productID = receipt.client_productID
        newReceipt.client_purchaseDate = receipt.client_purchaseDate
        newReceipt.client_expirationDate = receipt.client_expirationDate
        return newReceipt
    }
}

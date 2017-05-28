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
    
    public func realmFreeCopy() -> Receipt {
        let newReceipt = Receipt()
        newReceipt.pkcs7Data = self.pkcs7Data
        newReceipt.server_lastVerifyDate = self.server_lastVerifyDate
        newReceipt.server_appleStatusCode = self.server_appleStatusCode
        newReceipt.server_productID = self.server_productID
        newReceipt.server_purchaseDate = self.server_purchaseDate
        newReceipt.server_expirationDate = self.server_expirationDate
        newReceipt.client_originalCreationDate = self.client_originalCreationDate
        newReceipt.client_productID = self.client_productID
        newReceipt.client_purchaseDate = self.client_purchaseDate
        newReceipt.client_expirationDate = self.client_expirationDate
        return newReceipt
    }
}

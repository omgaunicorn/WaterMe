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
    
    private(set) public dynamic var client_originalCreationDate = Date()
    internal(set) public dynamic var client_productID: String?
    internal(set) public dynamic var client_purchaseDate: Date?
    internal(set) public dynamic var client_expirationDate: Date?
    
}

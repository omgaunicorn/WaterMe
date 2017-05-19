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
    internal(set) public dynamic var productIdentifier: String?
    internal(set) public dynamic var expirationDate: Date?
    internal(set) public dynamic var invalidationReasonCode = 0
    
}

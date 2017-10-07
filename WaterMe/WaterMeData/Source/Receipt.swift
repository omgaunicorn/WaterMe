//
//  Receipt.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/18/17.
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

import RealmSwift

public class Receipt: Object {
    
    @objc internal(set) public dynamic var pkcs7Data: Data?
    
    @objc internal(set) public dynamic var server_lastVerifyDate = Date()
    @objc internal(set) public dynamic var server_appleStatusCode: Int = -1
    @objc internal(set) public dynamic var server_productID: String?
    @objc internal(set) public dynamic var server_purchaseDate: Date?
    @objc internal(set) public dynamic var server_expirationDate: Date?
    
    @objc fileprivate(set) public dynamic var client_originalCreationDate = Date()
    @objc internal(set) public dynamic var client_lastVerifyDate = Date()
    @objc internal(set) public dynamic var client_productID: String?
    @objc internal(set) public dynamic var client_purchaseDate: Date?
    @objc internal(set) public dynamic var client_expirationDate: Date?
}

public extension Receipt {
    public func __admin_console_only_realmFreeCopy() -> Receipt {
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

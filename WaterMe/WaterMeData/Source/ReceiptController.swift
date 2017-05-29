//
//  ReceiptController.swift
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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import RealmSwift

public class ReceiptController {
    
    private static let objectTypes: [Object.Type] = [Receipt.self]
    
    public let user: SyncUser
    public let overridenUserPath: String?
    public let config: Realm.Configuration
    public var realm: Realm {
        return try! Realm(configuration: self.config)
    }
    
    public init(user: SyncUser, overrideUserPath: String? = nil) {
        self.user = user
        var realmConfig = Realm.Configuration()
        let url = user.realmURL(withAppName: "WaterMeReceipt", userPath: overrideUserPath)
        realmConfig.syncConfiguration = SyncConfiguration(user: user, realmURL: url, enableSSLValidation: true)
        realmConfig.schemaVersion = RealmSchemaVersion
        realmConfig.objectTypes = type(of: self).objectTypes
        self.overridenUserPath = overrideUserPath
        self.config = realmConfig
    }
    
    public var receipt: Receipt {
        return self.createReceiptIfNeeded()
    }
    
    public func updateReceipt(data: Data) {
        let receipt = self.createReceiptIfNeeded()
        let realm = self.realm
        realm.beginWrite()
        receipt.pkcs7Data = data
        try! realm.commitWrite()
    }
    
    public func __admin_console_only_UpdateReceipt(appleStatusCode: Int, productID: String?, purchaseDate: Date?, expirationDate: Date?) -> Receipt {
        let receipt = self.createReceiptIfNeeded()
        let realm = self.realm
        realm.beginWrite()
        receipt.server_appleStatusCode = appleStatusCode
        receipt.server_productID = productID
        receipt.server_purchaseDate = purchaseDate
        receipt.server_expirationDate = expirationDate
        receipt.server_lastVerifyDate = Date()
        try! realm.commitWrite()
        return receipt
    }
    
    public func updateReceipt(productID: String?, purchaseDate: Date?, expirationDate: Date?) {
        let receipt = self.createReceiptIfNeeded()
        let realm = self.realm
        realm.beginWrite()
        receipt.server_productID = productID
        receipt.server_purchaseDate = purchaseDate
        receipt.server_expirationDate = expirationDate
        try! realm.commitWrite()
    }
    
    public var receiptChanged: ((Receipt, ReceiptController) -> Void)? {
        didSet {
            if self.receiptChanged == nil {
                self.receiptToken?.stop()
                self.receiptToken = nil
            } else {
                self.configureReceiptNotificationsIfNeeded()
            }
        }
    }
    
    private func configureReceiptNotificationsIfNeeded() {
        guard self.receiptToken == nil else {
            // if the receipt token is already configured
            // we just want to call into the receiptChanged callback
            // this is so when this configure method is called
            // the callback gets called at least once
            self.receiptChanged?(self.receipt, self)
            return
        }
        self.receiptToken = realm.objects(Receipt.self).addNotificationBlock() { [weak self] changes in
            guard let weakSelf = self else { return }
            switch changes {
            case .initial(let data), .update(let data, _, _, _):
                guard let receipt = data.first else { return }
                self?.receiptChanged?(receipt, weakSelf)
            case .error(let error):
                log.error("Error reading receipt: \(error)")
            }
        }
    }
    
    private func createReceiptIfNeeded() -> Receipt {
        let realm = self.realm
        if let receipt = realm.objects(Receipt.self).first {
            return receipt
        } else {
            let receipt = Receipt()
            realm.beginWrite()
            realm.add(receipt)
            try! realm.commitWrite()
            return receipt
        }
    }
    
    private var receiptToken: NotificationToken?
    
    deinit {
        self.receiptToken?.stop()
    }
}

//
//  ReceiptController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/18/17.
//
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
    
    public func updateReceipt(data: Data?, productIdentifier: String?, expirationDate: Date?) {
        guard data != nil || expirationDate != nil else { return }
        let receipt = self.createReceiptIfNeeded()
        let realm = self.realm
        realm.beginWrite()
        if let data = data {
            receipt.pkcs7Data = data
        }
        if let productIdentifier = productIdentifier {
            receipt.productIdentifier = productIdentifier
        }
        if let expirationDate = expirationDate {
            receipt.expirationDate = expirationDate
        }
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

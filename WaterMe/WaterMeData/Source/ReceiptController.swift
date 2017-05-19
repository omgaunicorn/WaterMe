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
    
    private let user: SyncUser
    private let config: Realm.Configuration
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
        self.config = realmConfig
    }
    
    public var receipt: Receipt {
        return self.createReceiptIfNeeded()
    }
    
    public func updateReceipt(data: Data?, expirationDate: Date?) {
        guard data != nil || expirationDate != nil else { return }
        let receipt = self.createReceiptIfNeeded()
        let realm = self.realm
        realm.beginWrite()
        if let data = data {
            receipt.pkcs7Data = data
        }
        if let expirationDate = expirationDate {
            receipt.expirationDate = expirationDate
        }
        try! realm.commitWrite()
    }
    
    public var receiptChanged: ((Receipt) -> Void)? {
        didSet {
            if self.receiptChanged == nil {
                self.receiptToken?.stop()
                self.receiptToken = nil
            } else {
                self.configureReceiptNotificationsIfNeeded()
                self.receiptChanged?(self.receipt)
            }
        }
    }
    
    private func configureReceiptNotificationsIfNeeded() {
        guard self.receiptToken == nil else { return }
        self.receiptToken = realm.objects(Receipt.self).addNotificationBlock() { [weak self] changes in
            switch changes {
            case .initial(let data), .update(let data, _, _, _):
                guard let receipt = data.first else { return }
                self?.receiptChanged?(receipt)
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

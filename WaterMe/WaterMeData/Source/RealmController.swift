//
//  RealmController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/15/17.
//
//

import CloudKit
import RealmSwift

public protocol HasRealmControllers: class {
    var basicRealmController: RealmController! { get set }
    var proRealmController: RealmController? { get set }
}

public extension HasRealmControllers {
    public func configure(withBasic basic: RealmController?, andPro pro: RealmController?) {
        if let basic = basic {
            switch basic.kind {
            case .basic, .local:
                self.basicRealmController = basic
            case .pro:
                fatalError("Pro RealmController passed in as Non-Pro Controller")
            }
        }
        if let pro = pro {
            switch pro.kind {
            case .pro:
                self.proRealmController = pro
            case .local, .basic:
                fatalError("Non-Pro RealmController passed in as Pro Controller")
            }
        }
    }
}

public class RealmController {

    public let kind: Kind
    private let realmConfig: Realm.Configuration
    
    public var realm: Realm {
        switch self.kind {
        case .local:
            try! type(of: self).createLocalRealmDirectoryIfNeeded()
            let realm = try! Realm(configuration: self.realmConfig)
            return realm
        case .basic(let user), .pro(let user):
            let realm = try! Realm(configuration: self.realmConfig)
            return realm
        }
    }
    
    public init(kind: Kind, overrideUserPath: String = "~/") {
        self.kind = kind
        self.realmConfig = Realm.Configuration(kind: kind, userPath: overrideUserPath)
    }
    
    public var receipt: Receipt {
        return self.createReceiptIfNeeded()
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
        let receipts = realm.objects(Receipt.self)
        self.receiptToken = receipts.addNotificationBlock() { [unowned self] _ in
            self.receiptChanged?(self.receipt)
        }
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

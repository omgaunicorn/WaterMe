//
//  ReceiptWatcher.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import RealmSwift

class ReceiptWatcher {
    
    private let adminController = AdminRealmController()
    private var receiptControllers = [String : ReceiptController]()
    
    init() {
        let receipts = self.adminController.allReceiptFiles()
        self.notificationToken = receipts.addNotificationBlock() { [weak self] changes in self?.realmDataChanged(changes) }
    }
    
    private func realmDataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<RealmFile>>) {
        guard let user = SyncUser.current else { log.info("Can't watch receipts. No User logged in"); return; }
        switch changes {
        case .initial(let data), .update(let data, _, _, _):
            data.forEach() { file in
                guard let owningUserID = file.owner?.uuid else { return }
                self.createNewReceiptController(for: user, owningUserID: owningUserID)
            }
        case .error(let error):
            log.error(error)
        }
    }
    
    private func createNewReceiptController(for user: SyncUser, owningUserID: String) {
        guard self.receiptControllers[owningUserID] == nil else { return }
        let receipt = ReceiptController(user: user, overrideUserPath: owningUserID)
        self.receiptControllers[owningUserID] = receipt
        receipt.receiptChanged = { receipt in
            print("NewReceipt:\n \(receipt.pkcs7Data!)")
        }
    }
    
    private var notificationToken: NotificationToken?

    deinit {
        self.notificationToken?.stop()
    }

}

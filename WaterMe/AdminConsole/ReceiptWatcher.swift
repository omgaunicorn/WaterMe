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
        let receiptController = ReceiptController(user: user, overrideUserPath: owningUserID)
        self.receiptControllers[owningUserID] = receiptController
        receiptController.receiptChanged = { receipt, controller in
            guard let receiptData = receipt.pkcs7Data else { return }
            let jsonDict = [
                "receipt-data" : receiptData.base64EncodedString(),
                "password" : PrivateKeys.kReceiptValidationSharedSecret
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
            let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, request, error in
                let json = try! JSONSerialization.jsonObject(with: data!, options: [])
                print(json)
                print(request)
                print(error)
                print("done")
            }
            task.resume()
        }
    }
    
    private var notificationToken: NotificationToken?

    deinit {
        self.notificationToken?.stop()
    }

}

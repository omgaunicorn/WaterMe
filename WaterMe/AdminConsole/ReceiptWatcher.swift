//
//  ReceiptWatcher.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import Result
import WaterMeStore
import WaterMeData
import RealmSwift

class ReceiptWatcher {
    
    var inProgressChanged: ((Int) -> Void)?
    
    private let adminController = AdminRealmController()
    private var receiptControllers = [String : ReceiptController]()
    private var tasksInProgress = Set<String>() {
        didSet {
            self.inProgressChanged?(self.tasksInProgress.count)
        }
    }
    
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
        receiptController.receiptChanged = { [weak self] receipt, controller in
            self?.verify(receipt: receipt, from: controller)
        }
    }
    
    private func verify(receipt: Receipt, from controller: ReceiptController) {
        guard let userUUID = controller.overridenUserPath else {
            print("This controller is not configured correctly")
            return
        }
        let lastCheckedInterval = receipt.server_lastVerifyDate.timeIntervalSinceNow
        guard lastCheckedInterval <= -60 else {
            print("Not enough time has passed since last verification")
            return
        }
        guard let receiptData = receipt.pkcs7Data else {
            print("No receipt data found. Can't check receipt")
            return
        }
        self.tasksInProgress.insert(userUUID)
        URLSession.shared.validate(receiptData: receiptData) { result in
            switch result {
            case .success(let receiptStatus, let subscription):
                print("updating receipt in realm: \(receiptStatus) \(subscription)")
                let updatedReceipt = controller.__admin_console_only_UpdateReceipt(appleStatusCode: receiptStatus,
                                                                                   productID: subscription?.productID,
                                                                                   purchaseDate: subscription?.purchaseDate,
                                                                                   expirationDate: subscription?.expirationDate)
                guard let user = self.adminController.user(withUUID: userUUID) else { return }
                self.adminController.update(user: user, with: updatedReceipt)
            case .failure(let error):
                print(error)
            }
            self.tasksInProgress.remove(userUUID)
        }
    }
    
    private var notificationToken: NotificationToken?

    deinit {
        self.notificationToken?.stop()
    }
}

fileprivate extension PurchasedSubscription {
    init?(json: Any) {
        guard
            let dict = json as? NSDictionary,
            let expireMSString = dict["expires_date_ms"] as? String,
            let purchaseMSString = dict["purchase_date_ms"] as? String,
            let expireMS = Int(expireMSString),
            let purchaseMS = Int(purchaseMSString),
            let pID = dict["product_id"] as? String
        else { return nil }
        let expireDate = Date(timeIntervalSince1970: TimeInterval(expireMS / 1000))
        let purchaseDate = Date(timeIntervalSince1970: TimeInterval(purchaseMS / 1000))
        self.init(productID: pID, purchaseDate: purchaseDate, expirationDate: expireDate)
    }
}

fileprivate typealias AppleReceiptValidationResult = Result<(receiptStatus: Int, currentSubscription: PurchasedSubscription?), AnyError>

fileprivate extension URLSession {
    fileprivate func validate(receiptData: Data, completionHandler: ((AppleReceiptValidationResult) -> Void)?) {
        let prod = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        self.validate(receiptData: receiptData, url: prod, completionHandler: completionHandler)
    }
    
    fileprivate func validate(receiptData: Data, url: URL, completionHandler: ((AppleReceiptValidationResult) -> Void)?) {
        let jsonDict = [
            "receipt-data" : receiptData.base64EncodedString(),
            "password" : PrivateKeys.kReceiptValidationSharedSecret
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []) else {
            completionHandler?(.failure(AnyError("Unable to convert Receipt Data Payload into JSON for request.")))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler?(.failure(AnyError(error!))) }
                return
            }
            guard response.statusCode == 200 else {
                DispatchQueue.main.async { completionHandler?(.failure(AnyError("Unexpected HTTPResponse: \(response)"))) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completionHandler?(.failure(AnyError("No data received in response"))) }
                return
            }
            guard
                let _json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSObject,
                let json = _json,
                let status = json.value(forKeyPath: "status") as? Int
            else {
                DispatchQueue.main.async { completionHandler?(.failure(AnyError("Unable to convert response data into JSON"))) }
                return
            }
            guard status != 21007 else {
                // the receipt is a sandbox receipt, start over but with sandbox server instead
                let sandbox = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
                self.validate(receiptData: receiptData, url: sandbox, completionHandler: completionHandler)
                return
            }
            guard let purchasesArray = json.value(forKeyPath: "receipt.in_app") as? NSArray else {
                DispatchQueue.main.async { completionHandler?(.failure(AnyError("Unable to convert response data into JSON"))) }
                return
            }
            let validPurchases = purchasesArray
                .flatMap({ PurchasedSubscription(json: $0) })
                .sorted(by: { $0.0.expirationDate > $0.1.expirationDate })
            DispatchQueue.main.async { completionHandler?(.success(receiptStatus: status, currentSubscription: validPurchases.first)) }
        }
        task.resume()
    }
}

//
//  UserTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/24/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeStore
import UIKit

class UserTableViewCell: UITableViewCell {
    
    static let reuseID = "UserTableViewCell"
    
    @IBOutlet private weak var idLabel: UILabel?
    @IBOutlet private weak var sizeLabel: UILabel?
    @IBOutlet private weak var dataPresentLabel: UILabel?
    
    @IBOutlet private weak var serverStatusCodeLabel: UILabel?
    @IBOutlet private weak var serverExpirationDateLabel: UILabel?
    @IBOutlet private weak var serverProductIDLabel: UILabel?
    
    @IBOutlet private weak var clientExpirationDateLabel: UILabel?
    @IBOutlet private weak var clientProductIDLabel: UILabel?
    
    private let sizeFormatter: ByteCountFormatter = {
        let nf = ByteCountFormatter()
        nf.includesUnit = true
        nf.allowedUnits = [.useMB, .useGB, .useKB]
        return nf
    }()
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    func configure(with user: RealmUser) {
        self.idLabel?.text = user.uuid
        self.configureSizeLabel(with: user)
        self.configureDataPresentLabel(with: user)
        self.configureClientReceiptLabels(with: user)
        self.configureServerReceiptLabels(with: user)
    }
    
    private func configureClientReceiptLabels(with user: RealmUser) {
        guard
            let receipt = user.latestReceipt,
            let productID = receipt.client_productID,
            let purchaseDate = receipt.client_purchaseDate,
            let expirationDate = receipt.client_expirationDate,
            let sub = PurchasedSubscription(productID: productID, purchaseDate: purchaseDate, expirationDate: expirationDate)
        else {
            self.clientExpirationDateLabel?.text = "No Receipt Info"
            self.clientExpirationDateLabel?.textColor = .red
            return
        }
        self.clientProductIDLabel?.text = sub.productID
        self.clientExpirationDateLabel?.text = self.dateFormatter.string(from: sub.expirationDate)
        if sub.expirationDate.timeIntervalSinceNow < 0 {
            self.clientExpirationDateLabel?.textColor = .red
        }
    }
    
    private func configureServerReceiptLabels(with user: RealmUser) {
        guard
            let receipt = user.latestReceipt,
            let productID = receipt.server_productID,
            let purchaseDate = receipt.server_purchaseDate,
            let expirationDate = receipt.server_expirationDate,
            let sub = PurchasedSubscription(productID: productID, purchaseDate: purchaseDate, expirationDate: expirationDate)
            else {
                self.serverStatusCodeLabel?.text = "No Receipt Info"
                self.serverStatusCodeLabel?.textColor = .red
                return
        }
        let statusCode = receipt.server_appleStatusCode
        if statusCode != 0 {
            self.serverStatusCodeLabel?.textColor = .red
        }
        self.serverStatusCodeLabel?.text = String(statusCode)
        self.serverProductIDLabel?.text = sub.productID
        self.serverExpirationDateLabel?.text = self.dateFormatter.string(from: sub.expirationDate)
        if sub.expirationDate.timeIntervalSinceNow < 0 {
            self.serverExpirationDateLabel?.textColor = .red
        }
    }
    
    private func configureSizeLabel(with user: RealmUser) {
        self.sizeLabel?.text = self.sizeFormatter.string(fromByteCount: Int64(user.size))
        self.sizeLabel?.textColor = user.isSizeSuspicious ? .red : .darkText
    }
    
    private func configureDataPresentLabel(with user: RealmUser) {
        let dataPresent = user.dataPresent
        self.dataPresentLabel?.text = dataPresent.localizedString
        self.dataPresentLabel?.textColor = dataPresent.isSuspicious ? .red : .darkText
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.idLabel?.textColor = .darkText
        self.sizeLabel?.textColor = .darkText
        self.dataPresentLabel?.textColor = .darkText
        self.serverStatusCodeLabel?.textColor = .darkText
        self.clientExpirationDateLabel?.textColor = .darkText
        self.serverExpirationDateLabel?.textColor = .darkText
        
        self.idLabel?.text = nil
        self.sizeLabel?.text = nil
        self.dataPresentLabel?.text = nil
        
        self.serverStatusCodeLabel?.text = nil
        self.serverExpirationDateLabel?.text = nil
        self.serverProductIDLabel?.text = nil
        
        self.clientExpirationDateLabel?.text = nil
        self.clientProductIDLabel?.text = nil
    }
}

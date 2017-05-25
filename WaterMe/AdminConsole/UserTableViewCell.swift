//
//  UserTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/24/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    static let reuseID = "UserTableViewCell"
    
    @IBOutlet private weak var idLabel: UILabel?
    @IBOutlet private weak var sizeLabel: UILabel?
    @IBOutlet private weak var dataPresentLabel: UILabel?
    
    private let sizeFormatter: ByteCountFormatter = {
        let nf = ByteCountFormatter()
        nf.includesUnit = true
        nf.allowedUnits = [.useMB, .useGB, .useKB]
        return nf
    }()
    
    func configure(with user: RealmUser) {
        self.idLabel?.text = user.uuid
        self.sizeLabel?.text = self.sizeFormatter.string(fromByteCount: Int64(user.size))
        self.dataPresentLabel?.text = user.dataPresent.rawValue
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.idLabel?.textColor = UIColor.darkText
        self.sizeLabel?.textColor = UIColor.darkText
        self.dataPresentLabel?.textColor = UIColor.darkText
        
        self.idLabel?.text = nil
        self.sizeLabel?.text = nil
        self.dataPresentLabel?.text = nil
    }
}

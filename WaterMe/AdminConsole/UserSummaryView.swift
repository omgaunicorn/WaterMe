//
//  SummaryViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/22/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import RealmSwift
import UIKit

class UserSummmaryView: UIView {
    
    @IBOutlet private weak var totalUsersLabel: UILabel?
    @IBOutlet private weak var totalSizeLabel: UILabel?
    @IBOutlet private weak var totalPremUserCountLabel: UILabel?
    @IBOutlet private weak var totalProUserCountLabel: UILabel?
    @IBOutlet private weak var totalSuspectUserCountLabel: UILabel?
    @IBOutlet private weak var totalEmptyUserCountLabel: UILabel?
    
    private let adminController = AdminRealmController()
    
    private let sizeFormatter: ByteCountFormatter = {
        let nf = ByteCountFormatter()
        nf.includesUnit = false
        nf.allowedUnits = [.useMB]
        return nf
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let users = self.adminController.allUsers()
        self.notificationToken = users.addNotificationBlock() { [weak self] changes in self?.realmDataChanged(changes) }
    }
    
    private func realmDataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<RealmUser>>) {
        switch changes {
        case .initial(let data), .update(let data, _, _, _):
            self.updateUI(with: .success(data))
        case .error(let error):
            self.updateUI(with: .error(error))
        }
    }
    
    private func updateUI(with result: Result<AnyRealmCollection<RealmUser>>) {
        switch result {
        case .success(let data):
            self.totalUsersLabel?.text = String(data.count)
            self.totalSizeLabel?.text = self.sizeFormatter.string(fromByteCount: data.reduce(0, { $0.0 + Int64($0.1.size) }))
            let (premium, pro, suspicious, empty) = self.sumSubscriptionTypes(with: data)
            self.totalPremUserCountLabel?.text = String(premium)
            self.totalProUserCountLabel?.text = String(pro)
            self.totalSuspectUserCountLabel?.text = String(suspicious)
            self.totalEmptyUserCountLabel?.text = String(empty)
        case .error(let error):
            log.error(error)
        }
    }
    
    private func sumSubscriptionTypes(with data: AnyRealmCollection<RealmUser>) -> (prem: Int, pro: Int, suspicious: Int, empty: Int) {
        let dataPresents = data.map({ $0.dataPresent })
        let prem = dataPresents.filter({ $0 == .basic })
        let pro = dataPresents.filter({ $0 == .pro })
        let sus = dataPresents.filter({ $0 == .suspicious })
        let empty = dataPresents.filter({ $0 == .none })
        return (prem.count, pro.count, sus.count, empty.count)
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

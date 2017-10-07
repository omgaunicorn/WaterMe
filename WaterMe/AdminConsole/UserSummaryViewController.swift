//
//  UserSummaryViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/22/17.
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
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import Result
import WaterMeData
import RealmSwift
import UIKit

class UserSummaryViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let users = self.adminController.allUsers()
        self.notificationToken = users.addNotificationBlock() { [weak self] changes in self?.realmDataChanged(changes) }
    }
    
    private func realmDataChanged(_ changes: RealmCollectionChange<AnyRealmCollection<RealmUser>>) {
        switch changes {
        case .initial(let data), .update(let data, _, _, _):
            self.updateUI(with: data)
        case .error(let error):
            log.error(error)
            self.adminController.addError(with: (error as NSError).code, file: #file, function: #function, line: #line)
        }
    }
    
    private func updateUI(with data: AnyRealmCollection<RealmUser>) {
        self.totalUsersLabel?.text = String(data.count)
        self.totalSizeLabel?.text = self.sizeFormatter.string(fromByteCount: data.reduce(0, { $0 + Int64($1.size) }))
        let (premium, pro, suspicious, empty) = self.sumSubscriptionTypes(with: data)
        self.totalPremUserCountLabel?.text = String(premium)
        self.totalProUserCountLabel?.text = String(pro)
        self.totalSuspectUserCountLabel?.text = String(suspicious)
        self.totalEmptyUserCountLabel?.text = String(empty)
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

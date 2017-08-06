//
//  ViewController.swift
//  AdminConsole
//
//  Created by Jeffrey Bergier on 5/18/17.
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

import WaterMeData
import RealmSwift
import UIKit

class UserTableViewController: UITableViewController {

    private var users: AnyRealmCollection<RealmUser>?
    private let adminController = AdminRealmController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let users = self.adminController.allUsers()
        self.notificationToken = users.addNotificationBlock() { [weak self] changes in
            switch changes {
            case .initial(let data), .update(let data, _, _, _):
                self?.users = data
                self?.tableView?.reloadData()
            case .error(let error):
                self?.users = nil
                self?.tableView?.reloadData()
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = UserTableViewCell.reuseID
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        guard let userCell = cell as? UserTableViewCell, let user = self.users?[indexPath.row] else { return cell }
        userCell.configure(with: user)
        return userCell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = self.parent!.topLayoutGuide.length
        let bottomInset = self.parent!.bottomLayoutGuide.length
        self.tableView.contentInset.top = topInset
        self.tableView.contentInset.bottom = bottomInset
    }
    
    @IBAction private func unwindToUserTableViewController(_ segue: UIStoryboardSegue) { }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

//
//  ErrorTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/28/17.
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

import RealmSwift
import UIKit

class ErrorTableViewController: UITableViewController {
    
    private let adminController = AdminRealmController()
    private var data: AnyRealmCollection<ConsoleError>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let errors = self.adminController.allErrors()
        self.notificationToken = errors.addNotificationBlock({ [weak self] changes in self?.errorsChanged(changes) })
    }
    
    private func errorsChanged(_ changes: RealmCollectionChange<AnyRealmCollection<ConsoleError>>) {
        switch changes {
        case .initial(let data), .update(let data, _, _, _):
            self.data = data
            self.tableView.reloadData()
        case .error(let error):
            log.severe("Error Loading Errors. This is bad: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = ErrorTableViewCell.reuseID
        let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        guard let error = self.data?[indexPath.row], let cell = _cell as? ErrorTableViewCell else { return _cell }
        cell.configure(with: error)
        return cell
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
    
}

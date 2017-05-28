//
//  ErrorTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/28/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
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

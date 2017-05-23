//
//  ViewController.swift
//  AdminConsole
//
//  Created by Jeffrey Bergier on 5/18/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
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
        let id = "Basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        let data = self.users![indexPath.row]
        cell.textLabel?.text = data.uuid
        return cell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let topInset = self.parent!.topLayoutGuide.length
        let bottomInset = self.parent!.bottomLayoutGuide.length
        self.tableView.contentInset.top = topInset
        self.tableView.contentInset.bottom = bottomInset
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}


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

    var users: AnyRealmCollection<RealmUser>?
    let adminController = AdminRealmController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let users = self.adminController.allUsers()
        self.notificationToken = users.addNotificationBlock() { [weak self] changes in
            switch changes {
            case .initial(let data):
                self?.users = data
                self?.tableView?.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self?.tableView.endUpdates()
            case .error(let error):
                self?.users = nil
                self?.tableView?.reloadData()
                print(error)
            }
        }
        
        let url = WaterMeData.PrivateKeys.kRealmServer.appendingPathComponent("realmsec/list")
        var request = URLRequest(url: url)
        request.setValue("sharedSecret=\(PrivateKeys.requestSharedSecret)", forHTTPHeaderField: "Cookie")
        let task = URLSession.shared.dataTask(with: request) { _data, __response, error in
            let _response = __response as? HTTPURLResponse
            let _sharedSecret = (_response?.allHeaderFields["Shared-Secret"] ?? _response?.allHeaderFields["shared-secret"]) as? String
            guard
                let data = _data,
                let response = _response,
                let sharedSecret = _sharedSecret,
                response.statusCode == 200,
                sharedSecret == PrivateKeys.responseSharedSecret
            else { print(error ?? _response!); return; }
            self.adminController.processServerDirectoryData(data)
        }
        task.resume()
        
//        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: true)
    }
    
    var delete = true
    @objc private func timerFired(_ timer: NSObject?) {
        if self.delete {
            let realm = self.adminController.realm
            realm.beginWrite()
            realm.deleteAll()
            try! realm.commitWrite()
        } else {
            let data = PrivateKeys.jsonSampleData.data(using: .utf8)!
            self.adminController.processServerDirectoryData(data)
        }
        self.delete = !self.delete
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
    
    var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}


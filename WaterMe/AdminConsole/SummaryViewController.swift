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

class SummmaryViewController: UIViewController {
    
    @IBOutlet private weak var totalUsersLabel: UILabel?
    @IBOutlet private weak var totalSizeLabel: UILabel?
    @IBOutlet private weak var auditButton: UIButton?
    @IBOutlet private weak var refreshButton: UIButton?
    @IBOutlet private weak var deleteLocalButton: UIButton?
    private var buttons: [UIButton] {
        return [self.auditButton, self.refreshButton, self.deleteLocalButton].flatMap({ $0 })
    }
    
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
        self.notificationToken = users.addNotificationBlock() { [weak self] changes in
            switch changes {
            case .initial(let data), .update(let data, _, _, _):
                self?.totalUsersLabel?.text = String(data.count)
                self?.totalSizeLabel?.text = self?.sizeFormatter.string(fromByteCount: data.reduce(0, { $0.0 + Int64($0.1.size) }))
            case .error(let error):
                print(error)
            }
        }
    }
    
    @IBAction private func auditButtonTapped(_ sender: UIButton?) {
//        self.buttons.forEach({ $0.isEnabled = false })
    }
    
    @IBAction private func refreshButtonTapped(_ sender: UIButton?) {
        self.buttons.forEach({ $0.isEnabled = false })
        URLSession.shared.downloadROSFileTree() { result in
            switch result {
            case .success(let data):
                do {
                    try self.adminController.processServerDirectoryData(data)
                } catch {
                    print(error)
                }
            case .error(let error):
                print(error)
            }
            self.buttons.forEach({ $0.isEnabled = true })
        }
    }
    
    @IBAction private func deleteLocalButtonTapped(_ sender: UIButton?) {
        let deleteHandler: (UIAlertAction) -> Void = { _ in
            self.buttons.forEach({ $0.isEnabled = false })
            self.adminController.deleteAll()
            self.buttons.forEach({ $0.isEnabled = true })
        }
        let actionSheet = UIAlertController(cancelDeleteActionSheetWithDeleteHandler: deleteHandler, sourceView: sender)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension String: Error {}

extension URLSession {
    fileprivate func downloadROSFileTree(completionHandler: ((Result<Data>) -> Void)?) {
        let url = WaterMeData.PrivateKeys.kRealmServer.appendingPathComponent("realmsec/list")
        var request = URLRequest(url: url)
        request.setValue("sharedSecret=\(PrivateKeys.requestSharedSecret)", forHTTPHeaderField: "Cookie")
        let task = self.dataTask(with: request) { _data, __response, error in
            DispatchQueue.main.async {
                let _response = __response as? HTTPURLResponse
                let _sharedSecret = (_response?.allHeaderFields["Shared-Secret"] ?? _response?.allHeaderFields["shared-secret"]) as? String
                guard let data = _data, let response = _response, response.statusCode == 200 else {
                    completionHandler?(.error(__response?.debugDescription ?? error!))
                    return
                }
                guard let sharedSecret = _sharedSecret, sharedSecret == PrivateKeys.responseSharedSecret else {
                    completionHandler?(.error("SharedSecret does not match."))
                    return
                }
                completionHandler?(.success(data))
            }
        }
        task.resume()
    }
}

extension UIAlertController {
    convenience init(cancelDeleteActionSheetWithDeleteHandler deleteHandler: @escaping (UIAlertAction) -> Void, sourceView: UIView?) {
        self.init(title: nil, message: "Are you sure you want to delete this stuff?", preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: deleteHandler)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        self.addAction(delete)
        self.addAction(cancel)
        self.popoverPresentationController?.sourceView = sourceView
    }
}

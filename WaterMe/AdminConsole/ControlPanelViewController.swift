//
//  ControlPanelViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
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

extension Sequence {
    func first<T>(of type: T.Type? = nil) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

class ControlPanelViewController: UIViewController {
    
    /*@IBOutlet*/ private weak var receiptVerifyingViewController: ReceiptVerifyingViewController?
    @IBOutlet private weak var auditButton: UIButton?
    @IBOutlet private weak var refreshButton: UIButton?
    @IBOutlet private weak var deleteLocalButton: UIButton?
    private var buttons: [UIButton] {
        return [self.auditButton, self.refreshButton, self.deleteLocalButton].flatMap({ $0 })
    }
    
    private let adminController = AdminRealmController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.receiptVerifyingViewController = self.childViewControllers.first()!
    }
    
    @IBAction private func auditButtonTapped(_ sender: UIButton?) {
//        self.buttons.forEach({ $0.isEnabled = false })
    }
    
    @IBAction private func refreshButtonTapped(_ sender: UIButton?) {
        self.buttons.forEach({ $0.isEnabled = false })
        var isDownloadOpFinished = false
        var isRealmOpFinished = true
        if SyncUser.current == nil {
            log.info("Need to login to Realm")
            isRealmOpFinished = false
            SyncUser.adminLogin() { result in
                isRealmOpFinished = true
                switch result {
                case .success:
                    log.info("Login Succeeded")
                case .failure(let error):
                    log.error(error)
                    self.adminController.addError(with: error.rawValue, file: #file, function: #function, line: #line)
                }
                if isDownloadOpFinished && isRealmOpFinished {
                    self.buttons.forEach({ $0.isEnabled = true })
                    self.receiptVerifyingViewController?.reset()
                }
            }
        }
        URLSession.shared.downloadROSFileTree() { result in
            isDownloadOpFinished = true
            switch result {
            case .success(let data):
                self.adminController.processServerDirectoryData(data)
            case .failure(let error):
                log.error(error)
                self.adminController.addError(with: error.rawValue, file: #file, function: #function, line: #line)
            }
            if isDownloadOpFinished && isRealmOpFinished {
                self.buttons.forEach({ $0.isEnabled = true })
                self.receiptVerifyingViewController?.reset()
            }
        }
    }
    
    @IBAction private func deleteLocalButtonTapped(_ sender: UIButton?) {
        let deleteHandler: (UIAlertAction) -> Void = { _ in
            self.buttons.forEach({ $0.isEnabled = false })
            self.adminController.deleteAll()
            self.receiptVerifyingViewController?.reset()
            self.buttons.forEach({ $0.isEnabled = true })
        }
        let actionSheet = UIAlertController(cancelDeleteActionSheetWithDeleteHandler: deleteHandler, sourceView: sender)
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension String: Error {}

extension SyncUser {
    fileprivate class func adminLogin(completionHandler: ((Result<SyncUser, AdminRealmControllerError>) -> Void)?) {
        let server = WaterMeData.PrivateKeys.kRealmServer
        let credentials = SyncCredentials.usernamePassword(username: PrivateKeys.kRealmAdminLogin, password: PrivateKeys.kRealmAdminPassword, register: false)
        SyncUser.logIn(with: credentials, server: server) { user, error in
            DispatchQueue.main.async {
                if let user = user {
                    completionHandler?(.success(user))
                } else {
                    completionHandler?(.failure(.adminUserLoginError))
                }
            }
        }
    }
}

extension URLSession {
    fileprivate func downloadROSFileTree(completionHandler: ((Result<Data, AdminRealmControllerError>) -> Void)?) {
        let url = WaterMeData.PrivateKeys.kRealmServer.appendingPathComponent("realmsec/list")
        var request = URLRequest(url: url)
        request.setValue("sharedSecret=\(PrivateKeys.kRequestSharedSecret)", forHTTPHeaderField: "Cookie")
        let task = self.dataTask(with: request) { _data, __response, error in
            DispatchQueue.main.async {
                let _response = __response as? HTTPURLResponse
                let _sharedSecret = (_response?.allHeaderFields["Shared-Secret"] ?? _response?.allHeaderFields["shared-secret"]) as? String
                guard let data = _data, let response = _response, response.statusCode == 200 else {
                    completionHandler?(.failure(.unexpectedResponseFileListJSON))
                    return
                }
                guard let sharedSecret = _sharedSecret, sharedSecret == PrivateKeys.kResponseSharedSecret else {
                    completionHandler?(.failure(.invalidSharedSecretInResponseFileListJSON))
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

//
//  SummaryViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/22/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import UIKit

class SummmaryViewController: UIViewController {
    
    @IBOutlet private weak var auditButton: UIButton?
    @IBOutlet private weak var refreshButton: UIButton?
    @IBOutlet private weak var deleteLocalButton: UIButton?
    private var buttons: [UIButton] {
        return [self.auditButton, self.refreshButton, self.deleteLocalButton].flatMap({ $0 })
    }
    
    private let adminController = AdminRealmController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func auditButtonTapped(_ sender: UIButton?) {
//        self.buttons.forEach({ $0.isEnabled = false })
    }
    
    @IBAction private func refreshButtonTapped(_ sender: UIButton?) {
        self.buttons.forEach({ $0.isEnabled = false })
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
            DispatchQueue.main.async(execute: { self.buttons.forEach({ $0.isEnabled = true }) })
        }
        task.resume()
    }
    
    @IBAction private func deleteLocalButtonTapped(_ sender: UIButton?) {
        let deleteHandler: (UIAlertAction) -> Void = { _ in
            self.buttons.forEach({ $0.isEnabled = false })
            self.adminController.deleteAll()
            self.buttons.forEach({ $0.isEnabled = true })
        }
        
        let actionSheet = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        let delete = UIAlertAction(title: "Delete", style: .destructive, handler: deleteHandler)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(delete)
        actionSheet.addAction(cancel)
        actionSheet.popoverPresentationController?.sourceView = sender
        self.present(actionSheet, animated: true, completion: nil)
    }
}

//
//  ReceiptVerifyingViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/27/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class ReceiptVerifyingViewController: LoadingViewController {
    
    private let receiptWatcher = ReceiptWatcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.start()
        self.receiptWatcher.inProgressChanged = { [weak self] count in
            if count > 0 {
                self?.start()
            } else {
                self?.stop()
            }
        }
    }
    
    override func start() {
        super.start()
        self.label?.text = "Checking Receipts"
    }
    
    override func stop() {
        super.stop()
        self.label?.text = "Finished Checking Receipts"
    }
}

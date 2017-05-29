//
//  ReceiptVerifyingViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/27/17.
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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

class ReceiptVerifyingViewController: LoadingViewController {
    
    private var receiptWatcher = ReceiptWatcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reset()
    }
    
    func reset() {
        self.stop()
        self.receiptWatcher = ReceiptWatcher()
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

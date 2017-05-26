//
//  SynchronizingView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/25/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class SynchronizingView: UIView {
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView?
    @IBOutlet private weak var label: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.stop()
    }
    
    func start() {
        self.spinner?.startAnimating()
        self.label?.text = "Synchronizing..."
    }
    
    func stop() {
        self.spinner?.stopAnimating()
        self.label?.text = "Synchronized"
    }
}

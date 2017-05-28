//
//  LoadingViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/27/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView?
    @IBOutlet weak var label: UILabel?
    
    func start() {
        self.spinner?.startAnimating()
    }
    
    func stop() {
        self.spinner?.stopAnimating()
    }
}

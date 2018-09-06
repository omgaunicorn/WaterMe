//
//  TransparentTableViewHeaderFooterView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/5/18.
//  Copyright © 2018 Saturday Apps. All rights reserved.
//

import UIKit

class TransparentTableViewHeaderFooterView: UITableViewHeaderFooterView {

    static let reuseID = "TransparentTableViewHeaderFooterView"

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.backgroundView?.alpha = 0
    }

}

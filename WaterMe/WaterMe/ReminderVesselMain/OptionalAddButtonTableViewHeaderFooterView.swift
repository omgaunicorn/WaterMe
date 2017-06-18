//
//  OptionalAddButtonTableViewHeaderFooterView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/17/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class OptionalAddButtonTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    static let reuseID = "OptionalAddButtonTableViewHeaderFooterView"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }

    override func awakeFromNib() {
        super.awakeFromNib()
        print("Awake")
    }
    
}

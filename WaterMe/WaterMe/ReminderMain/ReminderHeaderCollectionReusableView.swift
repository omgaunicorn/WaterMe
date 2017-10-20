//
//  ReminderHeaderCollectionReusableView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 20/10/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class ReminderHeaderCollectionReusableView: UICollectionReusableView {

    static let reuseID = "ReminderHeaderCollectionReusableView"
    static let kind = UICollectionElementKindSectionHeader
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }

    @IBOutlet weak var label: UILabel?
    
}

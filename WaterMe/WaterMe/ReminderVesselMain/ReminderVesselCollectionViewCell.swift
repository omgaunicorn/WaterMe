//
//  ReminderVesselCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/31/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import UIKit

class ReminderVesselCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ReminderVesselCollectionViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

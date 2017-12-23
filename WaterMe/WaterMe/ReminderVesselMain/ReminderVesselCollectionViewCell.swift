//
//  ReminderVesselCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/31/17.
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
import UIKit

class ReminderVesselCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ReminderVesselCollectionViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    
    @IBOutlet private weak var nameLabel: UILabel?
    @IBOutlet private weak var emojiImageView: EmojiImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }
    
    func configure(with vessel: ReminderVessel) {
        let vesselName = vessel.displayName
        let vesselNameStyle = vesselName != nil ?
            Style.reminderVesselCollectionViewCellPrimary :
            Style.reminderVesselCollectionViewCellPrimaryDisabled
        self.nameLabel?.attributedText = NSAttributedString(string: vesselName ?? ReminderVessel.LocalizedString.untitledPlant,
                                                            style: vesselNameStyle)
        self.emojiImageView?.setIcon(vessel.icon)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.nameLabel?.attributedText = nil
        self.emojiImageView?.setIcon(nil)
    }

}

//
//  ReminderVesselIconTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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

class ReminderVesselIconTableViewCell: UITableViewCell {
    
    static let reuseID = "ReminderVesselIconTableViewCell"
    
    @IBOutlet private weak var emojiImageView: EmojiImageView?
    @IBOutlet private weak var emojiImageViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var cameraButton: UIButton?
    
    var iconButtonTapped: (() -> Void)?
    
    func configure(with icon: ReminderVessel.Icon?) {
        let cameraString = NSAttributedString(string: ReminderVessel.LocalizedString.photo, style: Style.reminderVesselCollectionViewCell, withTintColorFromView: self)
        self.cameraButton?.setAttributedTitle(cameraString, for: .normal)
        self.emojiImageView?.setIcon(icon)
    }
    
    @IBAction private func iconButtonTapped(_ sender: NSObject?) {
        self.iconButtonTapped?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cameraButton?.setAttributedTitle(nil, for: .normal)
        self.emojiImageView?.setIcon(nil)
        self.iconButtonTapped = nil
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.emojiImageViewHeightConstraint?.constant =
            UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory ?
                type(of: self).style_iconButtonHeightAccessibilityTextSizeEnabled :
                type(of: self).style_iconButtonHeightAccessibilityTextSizeDisabled
        
    }
}

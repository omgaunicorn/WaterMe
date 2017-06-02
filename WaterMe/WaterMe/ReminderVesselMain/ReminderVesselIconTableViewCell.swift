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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import WaterMeData
import UIKit

class ReminderVesselIconTableViewCell: UITableViewCell {
    
    static let reuseID = "ReminderVesselIconTableViewCell"
    
    @IBOutlet private weak var iconButton: UIButton?
    
    var iconButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconButton?.style_reminderVesselIconButton()
        log.debug()
    }
    
    func configure(with icon: ReminderVessel.Icon?) {
        self.iconButton?.setIcon(icon)
    }
    
    @IBAction private func iconButtonTapped(_ sender: NSObject?) {
        self.iconButtonTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.iconButton?.setTitle(nil, for: .normal)
        self.iconButtonTapped = nil
    }
}

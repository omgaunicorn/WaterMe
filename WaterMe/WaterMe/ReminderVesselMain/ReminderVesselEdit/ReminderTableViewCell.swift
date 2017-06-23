//
//  ReminderTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/18/17.
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

class ReminderTableViewCell: UITableViewCell {
    
    static let reuseID = "ReminderTableViewCell"
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var descriptionLabel: UILabel?
    @IBOutlet private weak var iconButton: UIButton?
    
    func configure(with reminder: Reminder?) {
        guard let reminder = reminder else { return }
        switch reminder.kind {
        case .water:
            self.titleLabel?.text = "Water Plant"
            self.descriptionLabel?.text = "Every \(reminder.interval) day(s)."
        case .fertilize:
            self.titleLabel?.text = "Fertilize Soil"
            self.descriptionLabel?.text = "Every \(reminder.interval) day(s)."
        case .move(let location):
            self.titleLabel?.text = "Move Plant to \(location)"
            self.descriptionLabel?.text = "Every \(reminder.interval) day(s)."
        case .other(let title, let description):
            self.titleLabel?.text = title
            self.descriptionLabel?.text = "Every \(reminder.interval) day(s)."
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        print("Awake")
    }

}

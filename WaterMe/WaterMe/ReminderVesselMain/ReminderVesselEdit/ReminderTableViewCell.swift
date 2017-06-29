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
    
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    static let reuseID = "ReminderTableViewCell"
    
    @IBOutlet private weak var topLabel: UILabel?
    @IBOutlet private weak var middleLabel: UILabel?
    @IBOutlet private weak var bottomLabel: UILabel?
    @IBOutlet private weak var iconButton: UIButton?
    
    func configure(with reminder: Reminder?) {
        guard let reminder = reminder else { return }
        switch reminder.kind {
        case .water:
            self.topLabel?.text = "Water Plant"
            self.middleLabel?.isHidden = true
            self.bottomLabel?.text = "Every \(reminder.interval) day(s)."
        case .fertilize:
            self.topLabel?.text = "Fertilize Soil"
            self.middleLabel?.isHidden = true
            self.bottomLabel?.text = "Every \(reminder.interval) day(s)."
        case .move(let location):
            self.topLabel?.text = "Move Plant"
            self.middleLabel?.text = location ?? "No location configured"
            self.bottomLabel?.text = String(reminder.interval)
        case .other(let title, let description):
            self.topLabel?.text = title
            self.middleLabel?.text = description ?? "No description"
            self.bottomLabel?.text = String(reminder.interval)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }
    
    override func prepareForReuse() {
        self.topLabel?.text = nil
        self.middleLabel?.text = nil
        self.bottomLabel?.text = nil
        self.middleLabel?.isHidden = false
    }

}

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
            self.topLabel?.attributedText = NSAttributedString(string: "Water Plant", style: .selectableTableViewCell)
            self.middleLabel?.isHidden = true
            self.bottomLabel?.attributedText = NSAttributedString(string: String(reminder.interval), style: .readOnlyTableViewCell)
        case .fertilize:
            self.topLabel?.attributedText = NSAttributedString(string: "Fertilize Soil", style: .selectableTableViewCell)
            self.middleLabel?.isHidden = true
            self.bottomLabel?.attributedText = NSAttributedString(string: String(reminder.interval), style: .readOnlyTableViewCell)
        case .move(let location):
            self.topLabel?.attributedText = NSAttributedString(string: "Move Plant", style: .selectableTableViewCell)
            if let location = location {
                self.middleLabel?.attributedText = NSAttributedString(string: location, style: .selectableTableViewCell)
            } else {
                self.middleLabel?.isHidden = true
            }
            self.bottomLabel?.attributedText = NSAttributedString(string: String(reminder.interval), style: .readOnlyTableViewCell)
        case .other(let title, let description):
            self.topLabel?.attributedText = NSAttributedString(string: title ?? "Other", style: .selectableTableViewCell)
            if let description = description {
                self.middleLabel?.attributedText = NSAttributedString(string: description, style: .selectableTableViewCell)
            } else {
                self.middleLabel?.isHidden = true
            }
            self.bottomLabel?.attributedText = NSAttributedString(string: String(reminder.interval), style: .readOnlyTableViewCell)
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
        self.topLabel?.isHidden = false
        self.middleLabel?.isHidden = false
        self.bottomLabel?.isHidden = false
    }

}

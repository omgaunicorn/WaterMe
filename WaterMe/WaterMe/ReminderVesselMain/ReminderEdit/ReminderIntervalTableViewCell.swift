//
//  ReminderIntervalTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/24/17.
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

import UIKit

class ReminderIntervalTableViewCell: UITableViewCell {
    
    static let reuseID = "ReminderIntervalTableViewCell"
    
    @IBOutlet private weak var label: UILabel?
    
    fileprivate let formatter = DateComponentsFormatter.newReminderIntervalFormatter
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.label?.style_calloutFontLabel()
        self.prepareForReuse()
    }
    
    func configure(with interval: Int) {
        let time = TimeInterval(interval) * (60 * 60 * 24)
        let string = self.formatter.string(from: time) ?? "–"
        self.label?.text = string
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label?.text = nil
    }
    
}

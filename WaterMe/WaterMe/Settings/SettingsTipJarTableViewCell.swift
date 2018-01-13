//
//  SettingsTipJarTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/1/18.
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

class SettingsTipJarTableViewCell: UITableViewCell {

    class var reuseID: String { return "SettingsTipJarTableViewCell" }

    let leadingLabel = UILabel()
    let trailingLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    func setup() {
        self.leadingLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.trailingLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.leadingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.trailingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.leadingLabel)
        self.contentView.addSubview(self.trailingLabel)
        self.contentView.addConstraints([
            self.leadingLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: UITableViewCell.style_labelCellLeadingPadding),
            self.leadingLabel.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: UITableViewCell.style_labelCellTopPadding),
            self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: self.leadingLabel.bottomAnchor, constant: UITableViewCell.style_labelCellBottomPadding),
            self.trailingLabel.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: UITableViewCell.style_labelCellTopPadding),
            self.contentView.bottomAnchor.constraint(greaterThanOrEqualTo: self.trailingLabel.bottomAnchor, constant: UITableViewCell.style_labelCellBottomPadding),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingLabel.trailingAnchor, constant: UITableViewCell.style_labelCellTrailingPadding),
            self.leadingLabel.firstBaselineAnchor.constraint(equalTo: self.trailingLabel.firstBaselineAnchor, constant: 0),
            self.trailingLabel.leadingAnchor.constraintGreaterThanOrEqualToSystemSpacingAfter(self.leadingLabel.trailingAnchor, multiplier: 1)
            ])
    }
    func configure(with row: SettingsTableViewController.TipJarRows, price: String?) {
        let title = row.localizedTitle
        let price = price ?? "–"
        let leadingString = NSAttributedString(string: title, style: .selectableTableViewCell)
        let trailingString = NSAttributedString(string: price, style: .selectableTableViewCellDisabled)
        self.leadingLabel.attributedText = leadingString
        self.trailingLabel.attributedText = trailingString
    }
    
}

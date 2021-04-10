//
//  SimpleToggleTableViewCell.swift
//  WaterMe
//
//  Created by execjosh on 2021/04/01.
//  Copyright © 2021 Saturday Apps.
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

class SimpleToggleTableViewCell: SimpleLabelTableViewCell {

    override class var reuseID: String { return "SimpleToggleTableViewCell" }

    let toggle = UISwitch()
    var toggleChanged: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    override func setup() {
        super.setup()
        self.selectionStyle = .none
        self.accessoryView = self.toggle
        self.toggle.addTarget(self, action: #selector(userToggledSwitch(_:)), for: .valueChanged)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.toggle.isOn = false
        self.textLabel?.text = nil
        self.toggleChanged = nil
    }

    @objc private func userToggledSwitch(_ toggle: UISwitch) {
        let newIsEnabled = toggle.isOn
        self.toggleChanged?(newIsEnabled)
    }
}

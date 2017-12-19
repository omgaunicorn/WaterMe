//
//  ReminderKindTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/23/17.
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

class ReminderKindTableViewCell: SimpleLabelTableViewCell {
    
    static let reuseID = "ReminderKindTableViewCell"
    
    override func setup() {
        super.setup()
        self.prepareForReuse()
    }
    
    func configure(rowNumber: Int, compareWith compare: Reminder.Kind) {
        let id = Reminder.Kind(row: rowNumber)
        self.label.attributedText = NSAttributedString(string: id.localizedString, style: Style.selectableTableViewCell)
        self.accessoryType = id.isSameKind(as: compare) ? .checkmark : .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.attributedText = nil
    }
    
}

extension Reminder.Kind {
    fileprivate var localizedString: String {
        switch self {
        case .water:
            return LocalizedString.water
        case .fertilize:
            return LocalizedString.fertilize
        case .move:
            return LocalizedString.move
        case .other:
            return LocalizedString.other
        }
    }
    fileprivate func isSameKind(as other: Reminder.Kind) -> Bool {
        switch self {
        case .water:
            guard case .water = other else { return false }
            return true
        case .fertilize:
            guard case .fertilize = other else { return false }
            return true
        case .move:
            guard case .move = other else { return false }
            return true
        case .other:
            guard case .other = other else { return false }
            return true
        }
    }
    init(row: Int) {
        switch row {
        case 0:
            self = .water
        case 1:
            self = .fertilize
        case 2:
            self = .move(location: nil)
        case 3:
            self = .other(description: nil)
        default:
            fatalError("Too Many Rows in Section")
        }
    }
}

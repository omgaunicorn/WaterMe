//
//  ReminderKindTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/23/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import UIKit

class ReminderKindTableViewCell: UITableViewCell {
    
    static let reuseID = "ReminderKindTableViewCell"
    
    func configure(rowNumber: Int, compareWith compare: Reminder.Kind) {
        let id = Reminder.Kind(row: rowNumber)
        self.textLabel?.text = id.localizedString
        self.accessoryType = id.isSameKind(as: compare) ? .checkmark : .none
    }
    
}

extension Reminder.Kind {
    fileprivate var localizedString: String {
        switch self {
        case .water:
            return "Water"
        case .fertilize:
            return "Fertilize"
        case .move:
            return "Move"
        case .other:
            return "Other"
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
            self = .other(title: nil, description: nil)
        default:
            fatalError("Too Many Rows in Section")
        }
    }
}

//
//  ReminderTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/18/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
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

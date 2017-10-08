//
//  ReminderCollectionViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 08/10/17.
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

class ReminderCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ReminderCollectionViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    
    @IBOutlet private weak var topLabel: UILabel?
    @IBOutlet private weak var middleLabel: UILabel?
    @IBOutlet private weak var bottomLabel: UILabel?
    @IBOutlet private weak var largeEmojiImageView: EmojiImageView?
    @IBOutlet private weak var smallEmojiImageView: EmojiImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with reminder: Reminder) {
        print(reminder.kind)
        print(reminder.vessel!.displayName)
    }

}

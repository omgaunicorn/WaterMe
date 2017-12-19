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

import FormatterKit
import WaterMeData
import UIKit

class ReminderCollectionViewCell: UICollectionViewCell {
    
    static let reuseID = "ReminderCollectionViewCell"
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    
    @IBOutlet private weak var labelOne: UILabel?
    @IBOutlet private weak var labelTwo: UILabel?
    @IBOutlet private weak var labelThree: UILabel?
    @IBOutlet private weak var labelFour: UILabel?
    @IBOutlet private weak var largeEmojiImageView: EmojiImageView?
    @IBOutlet private weak var smallEmojiImageView: EmojiImageView?
    
    private let reminderDateFormatter = TTTTimeIntervalFormatter.newTimeAgoFormatter

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.largeEmojiImageView?.size = .large
        self.smallEmojiImageView?.size = .small
        self.reset()
    }
    
    func configure(with reminder: Reminder?) {
        guard let reminder = reminder else { self.reset(); return; }
        
        // vessel name style
        let vesselName = reminder.vessel?.displayName
        let vesselNameStyle = vesselName != nil ?
            Style.reminderVesselCollectionViewCell :
            Style.reminderVesselCollectionViewCellDisabled
        self.labelOne?.attributedText = NSAttributedString(string: vesselName ?? ReminderVessel.LocalizedString.untitledPlant,
                                                           style: vesselNameStyle)

        // other stuff
        self.labelTwo?.attributedText = NSAttributedString(string: reminder.kind.stringValue, style: .selectableTableViewCell)
        self.largeEmojiImageView?.setIcon(reminder.vessel?.icon)
        self.smallEmojiImageView?.setKind(reminder.kind)
        
        // relative time
        let interval = reminder.nextPerformDate?.timeIntervalSinceNow
        let intervalString = interval != nil ?
            self.reminderDateFormatter.string(forTimeInterval: interval!) :
            ReminderMainViewController.LocalizedString.nextPerformLabelNow
        self.labelFour?.attributedText = NSAttributedString(string: intervalString!, style: .selectableTableViewCell)
        
        // put in the auxiliary text
        switch reminder.kind {
        case .fertilize, .water:
            self.labelThree?.isHidden = true
        case .move(let auxString), .other(let auxString):
            if let auxString = auxString {
                self.labelThree?.isHidden = false
                self.labelThree?.attributedText = NSAttributedString(string: auxString, style: .readOnlyTableViewCell)
            } else {
                self.labelThree?.isHidden = true
            }
        }
    }
    
    private func reset() {
        self.labelOne?.text = nil
        self.labelTwo?.text = nil
        self.labelThree?.text = nil
        self.labelFour?.text = nil
        self.labelTwo?.isHidden = false
        self.largeEmojiImageView?.setKind(nil)
        self.smallEmojiImageView?.setKind(nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.reset()
    }

}

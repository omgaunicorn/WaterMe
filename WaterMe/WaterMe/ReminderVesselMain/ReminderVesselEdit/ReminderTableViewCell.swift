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

import Datum
import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }
    static let reuseID = "ReminderTableViewCell"
    
    @IBOutlet private weak var topLabel: UILabel?
    @IBOutlet private weak var middleLabel: UILabel?
    @IBOutlet private weak var bottomLabel: UILabel?
    @IBOutlet private weak var emojiImageView: EmojiImageView?

    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var trailingConstraint: NSLayoutConstraint?
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint?

    fileprivate let formatter = DateComponentsFormatter.newReminderIntervalFormatter
    
    func configure(with reminder: Reminder?) {
        guard let reminder = reminder else { self.reset(); return; }
        
        // do stuff that is the same for all cases
        self.topLabel?.attributedText = NSAttributedString(string: reminder.kind.localizedShortString, font: .selectableTableViewCell)
        let interval = NSAttributedString(string: self.formatter.string(forDayInterval: reminder.interval), font: .selectableTableViewCell)
        let helper = NSAttributedString(string: ReminderVesselEditViewController.LocalizedString.rowLabelInterval,
                                        font: .selectableTableViewCellHelper)
        self.middleLabel?.attributedText = helper + interval
        self.emojiImageView?.setKind(reminder.kind)
        if !reminder.isEnabled {
            self.backgroundColor = UIColor.red // TODO devise a better UI to convey disabled reminders
        }
        
        // do stuff that is case specific
        switch reminder.kind {
        case .water, .fertilize, .trim, .mist:
            self.bottomLabel?.isHidden = true
        case .move(let location):
            let style: Font = location != nil ? .selectableTableViewCell : .selectableTableViewCellDisabled
            let helper = NSAttributedString(string: ReminderVesselEditViewController.LocalizedString.rowLabelLocation,
                                            font: .selectableTableViewCellHelper)
            let location = NSAttributedString(string: location ?? ReminderVesselEditViewController.LocalizedString.rowValueLabelLocationNoValue, font: style)
            self.bottomLabel?.attributedText = helper + location
        case .other(let description):
            let style: Font = description != nil ? .selectableTableViewCell : .selectableTableViewCellDisabled
            let helper = NSAttributedString(string: ReminderVesselEditViewController.LocalizedString.rowLabelDescription,
                                            font: .selectableTableViewCellHelper)
            let description = NSAttributedString(string: description ?? ReminderVesselEditViewController.LocalizedString.rowValueLabelDescriptionNoValue,
                                                 font: style)
            self.bottomLabel?.attributedText = helper + description
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.emojiImageView?.backgroundColor = .clear
        self.emojiImageView?.size = .small
        self.emojiImageView?.ring = false
        self.leadingConstraint?.constant = UITableViewCell.style_labelCellLeadingPadding
        self.trailingConstraint?.constant = UITableViewCell.style_labelCellTrailingPadding
        self.topConstraint?.constant = UITableViewCell.style_labelCellTopPadding
        self.bottomConstraint?.constant = UITableViewCell.style_labelCellBottomPadding

        self.reset()
    }
    
    private func reset() {
        self.topLabel?.text = nil
        self.middleLabel?.text = nil
        self.bottomLabel?.text = nil
        self.topLabel?.isHidden = false
        self.middleLabel?.isHidden = false
        self.bottomLabel?.isHidden = false
        self.emojiImageView?.setKind(nil)
        self.backgroundColor = nil
    }
    
    override func prepareForReuse() {
        self.reset()
    }

}

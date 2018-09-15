//
//  ReminderSummaryReminderVesselIconTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/15/18.
//  Copyright © 2018 Saturday Apps.
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

class ReminderSummaryReminderVesselIconTableViewCell: ReminderVesselIconTableViewCell {

    @IBOutlet private(set) weak var highlightView: UIView?
    @IBOutlet private weak var cornerRadiusView: UIView?
    var locationInGroup: VerticalLocationInGroup = .alone

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let change = {
            self.highlightView?.alpha = highlighted ?
                ReminderSummaryViewController.style_tableViewHighlightAlpha : 0
        }
        guard animated else {
            change()
            return
        }
        UIView.style_animateNormal {
            change()
        }
        super.setHighlighted(highlighted, animated: animated)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let change = {
            self.highlightView?.alpha = selected ?
                ReminderSummaryViewController.style_tableViewHighlightAlpha : 0
        }
        guard animated else {
            change()
            return
        }
        UIView.style_animateNormal {
            change()
        }
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        if let crv = self.cornerRadiusView {
            crv.style_setCornerRadius()
            crv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: crv.layer)
        }
        if let hlv = self.highlightView {
            hlv.style_setCornerRadius()
            hlv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: hlv.layer)
        }
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.locationInGroup = .alone
        self.highlightView?.backgroundColor = .black
        self.highlightView?.alpha = 0
    }
}

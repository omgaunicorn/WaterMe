//
//  SingleLabelTableViewCell.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/5/18.
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

class RoundedBackgroundViewTableViewCell: UITableViewCell {

    @IBOutlet private(set) weak var cornerRadiusView: UIView?
    @IBOutlet private(set) weak var hairlineView: UIView?

    var locationInGroup: VerticalLocationInGroup = .alone {
        didSet {
            switch self.locationInGroup {
            case .alone, .bottom:
                self.hairlineView?.isHidden = true
            case .top, .middle:
                self.hairlineView?.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.prepareForReuse()
    }

    override func layoutSubviews() {
        if let crv = self.cornerRadiusView {
            crv.style_setCornerRadius()
            crv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: crv.layer)
        }
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.locationInGroup = .alone
        self.hairlineView?.backgroundColor = .clear
    }

}

class ButtonTableViewCell: RoundedBackgroundViewTableViewCell {

    @IBOutlet private(set) weak var label: UILabel?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.label?.text = nil
    }
}

class InfoTableViewCell: RoundedBackgroundViewTableViewCell {

    @IBOutlet private(set) weak var vesselNameLabel: UILabel?
    @IBOutlet private(set) weak var vesselNameSublabel: UILabel?

    @IBOutlet private(set) weak var reminderKindLabel: UILabel?
    @IBOutlet private(set) weak var reminderKindSublabel: UILabel?

    @IBOutlet private(set) weak var lastPerformDateLabel: UILabel?
    @IBOutlet private(set) weak var lastPerformDateSublabel: UILabel?

    @IBOutlet private(set) weak var nextPerformDateLabel: UILabel?
    @IBOutlet private(set) weak var nextPerformDateSublabel: UILabel?

    @IBOutlet private(set) weak var noteLabel: UILabel?
    @IBOutlet private(set) weak var noteSublabel: UILabel?

    override func prepareForReuse() {
        super.prepareForReuse()
        self.vesselNameLabel?.text = nil
        self.vesselNameSublabel?.text = nil
        self.reminderKindSublabel?.text = nil
        self.lastPerformDateLabel?.text = nil
        self.nextPerformDateSublabel?.text = nil
        self.noteLabel?.text = nil
        self.noteSublabel?.text = nil
    }
}

class ReminderSummaryReminderVesselIconTableViewCell: ReminderVesselIconTableViewCell {

    @IBOutlet private weak var cornerRadiusView: UIView?
    var locationInGroup: VerticalLocationInGroup = .alone

    override func layoutSubviews() {
        super.layoutSubviews()

        if let crv = self.cornerRadiusView {
            crv.style_setCornerRadius()
            crv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: crv.layer)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.locationInGroup = .alone
    }
}

enum VerticalLocationInGroup {

    case alone, bottom, top, middle

    func configureCornerMask(on layer: CALayer) {
        switch self {
        case .alone:
            layer.maskedCorners = [
                .layerMaxXMaxYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMinXMinYCorner
            ]
        case .bottom:
            layer.maskedCorners = [
                .layerMaxXMaxYCorner,
                .layerMinXMaxYCorner
            ]
        case .middle:
            layer.maskedCorners = []
        case .top:
            layer.maskedCorners = [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner
            ]
        }
    }
}

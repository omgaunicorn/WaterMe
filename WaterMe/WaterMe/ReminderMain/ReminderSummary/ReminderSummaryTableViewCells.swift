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

    var locationInGroup: VerticalLocationInGroup = .alone
    @IBOutlet weak var cornerRadiusView: UIView?

    override func layoutSubviews() {
        if let crv = self.cornerRadiusView {
            let height = crv.frame.height
            let desiredRadius = UIApplication.style_cornerRadius
            crv.layer.cornerRadius = minMaxCornerRadius(withViewHeight: height,
                                                        desiredRadius: desiredRadius)
            crv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: crv.layer)
        }
        super.layoutSubviews()
    }

}

class ButtonTableViewCell: RoundedBackgroundViewTableViewCell {

    @IBOutlet private(set) weak var label: UILabel?

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

    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.locationInGroup = .alone
    }
}

class ReminderSummaryReminderVesselIconTableViewCell: ReminderVesselIconTableViewCell {

    @IBOutlet private weak var cornerRadiusView: UIView?
    var locationInGroup: VerticalLocationInGroup = .alone

    override func layoutSubviews() {
        super.layoutSubviews()

        if let crv = self.cornerRadiusView {
            let height = crv.frame.height
            let desiredRadius = UIApplication.style_cornerRadius
            crv.layer.cornerRadius = minMaxCornerRadius(withViewHeight: height,
                                                        desiredRadius: desiredRadius)
            crv.clipsToBounds = true
            self.locationInGroup.configureCornerMask(on: crv.layer)
        }
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

func minMaxCornerRadius(withViewHeight height: CGFloat, desiredRadius: CGFloat) -> CGFloat {
    let radius: CGFloat
    if height / 2 > desiredRadius {
        radius = desiredRadius
    } else {
        radius = height / 2
    }
    return radius
}

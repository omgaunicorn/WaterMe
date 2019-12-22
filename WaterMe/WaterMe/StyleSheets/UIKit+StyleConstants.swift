//
//  UIKit+StyleConstants.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/20/18.
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

import CropViewController
import UIKit

extension UIView {
    class func style_animateNormal(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        self.animate(withDuration: UIApplication.style_animationDurationNormal,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: completion)
    }
    class func style_animateNormal(_ animations: @escaping () -> Void) {
        self.animate(withDuration: UIApplication.style_animationDurationNormal,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: nil)
    }
    class func style_animateLong(_ animations: @escaping () -> Void, completion: @escaping ((Bool) -> Void)) {
        self.animate(withDuration: UIApplication.style_animationDurationLong,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: completion)
    }
    class func style_animateLong(_ animations: @escaping () -> Void) {
        self.animate(withDuration: UIApplication.style_animationDurationLong,
                     delay: 0,
                     options: [],
                     animations: animations,
                     completion: nil)
    }
}

extension ReminderHeaderCollectionReusableView {
    class func style_viewHeight(isAccessibilityCategory: Bool) -> CGFloat {
        switch isAccessibilityCategory {
        case true:
            return 74
        case false:
            return 44
        }
    }
}

extension ModalParentViewController {
    enum Style {
        static let grayViewColor = UIColor.black.withAlphaComponent(0.5)
    }
}

extension UIApplication {
    static let style_animationDurationLong: TimeInterval = 1.2
    static let style_animationDurationNormal: TimeInterval = 0.3
    static let style_cornerRadius: CGFloat = 12
    class func style_configure() {
        UIView.appearance().tintColor = Color.tint
        UIView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = nil
        UIImageView.appearance(whenContainedInInstancesOf: [ReminderTableViewCell.self]).tintColor = Color.textSecondary
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [CropViewController.self]).backgroundColor = nil
        UIVisualEffectView.appearance().backgroundColor = Color.visuelEffectViewBackground

extension UIWindow {
    func style_configure() {
        // configure dark mode
        let ud = UserDefaults.standard
        if #available(iOS 13.0, *) {
            switch ud.darkMode {
            case .system:
                self.overrideUserInterfaceStyle = .unspecified
            case .forceLight:
                self.overrideUserInterfaceStyle = .light
            case .forceDark:
                self.overrideUserInterfaceStyle = .dark
            }
        }
    }
}

extension UIView {
    func style_setCornerRadius() {
        self.layer.cornerRadius = self.maxCornerRadius(withDesiredRadius: UIApplication.style_cornerRadius)
    }
}

extension ReminderSummaryViewController {
    static let style_leadingTrailingPadding: CGFloat = 8
    static let style_bottomPadding: CGFloat = style_leadingTrailingPadding
    static let style_topPadding: CGFloat = style_bottomPadding / 2
    static let style_tableViewSectionGap: CGFloat = 8
    static let style_tableViewHighlightAlpha: CGFloat = 0.1
    static let style_actionButtonSeparatorColor: UIColor = Color.tint.withAlphaComponent(0.2)
    static let style_primaryLabelSublabelSpacing: CGFloat = 4
}

extension DragTargetInstructionalView {
    static let style_animationDurationLong: TimeInterval = 2
    static let style_animationDurationNormal: TimeInterval = 1
    static let style_animationDelayLong: TimeInterval = 4
    static let style_animationDelayNormal: TimeInterval = 1
}

extension ReminderFinishDropTargetViewController {
    static let style_dropTargetViewCompactHeight: CGFloat = 88
    static let style_dropTargetViewCompactHeightAccessibilityTextSizeEnabled: CGFloat = 132
}

extension ReminderCollectionViewCell {
    static let style_emojiImageViewWidth: CGFloat = 100
    static let style_emojiImageViewWidthAccessibility: CGFloat = 170
}

extension UITableViewCell {
    static let style_labelCellTopPadding: CGFloat = 12
    static let style_labelCellBottomPadding: CGFloat = 12
    static let style_labelCellLeadingPadding: CGFloat = 16
    static let style_labelCellTrailingPadding: CGFloat = 16

    static let style_textFieldCellTopPadding: CGFloat = 7
    static let style_textFieldCellBottomPadding: CGFloat = 6
    static let style_textFieldCellLeadingPadding: CGFloat = 16
    static let style_textFieldCellTrailingPadding: CGFloat = 16
}

extension TextViewTableViewCell {
    static let style_cellHeightAccessibilityTextSizeEnabled: CGFloat = 400
    static let style_cellHeightAccessibilityTextSizeDisabled: CGFloat = 200
}

extension ReminderVesselIconTableViewCell {
    static let style_iconButtonHeightAccessibilityTextSizeEnabled: CGFloat = 280
    static let style_iconButtonHeightAccessibilityTextSizeDisabled: CGFloat = 140
}

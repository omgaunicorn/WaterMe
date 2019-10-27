//
//  UIBarButtonItem+WaterMe.swift
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

import UIKit

extension UIBarButtonItem {
    convenience init(localizedSettingsButtonWithTarget target: Any,
                     action: Selector)
    {
        self.init(image: #imageLiteral(resourceName: "TipJar"), style: UIBarButtonItem.Style.plain,
                  target: target,
                  action: action)
        self.accessibilityLabel = SettingsMainViewController.LocalizedString.settingsTitle
    }
    convenience init(localizedDeleteButtonWithTarget target: Any,
                     action: Selector)
    {
        self.init(title: UIAlertController.LocalizedString.buttonTitleDelete,
                  style: .plain,
                  target: target,
                  action: action)
        self.tintColor = Color.delete
    }
    convenience init(localizedDoneButtonWithTarget target: Any,
                     action: Selector)
    {
        self.init(barButtonSystemItem: .done,
                  target: target,
                  action: action)
        self.style = .done
    }
    convenience init(localizedAddReminderVesselBBIButtonWithTarget target: Any,
                     action: Selector)
    {
        self.init(title: UIAlertController.LocalizedString.buttonTitleAddPlant,
                  style: .done,
                  target: target,
                  action: action)
    }
    convenience init(__legacy_localizedAddReminderVesselBBIButtonWithTarget target: Any,
                     action: Selector)
    {
        self.init(title: UIAlertController.LocalizedString.buttonTitleAddPlant,
                  style: .plain,
                  target: target,
                  action: action)
    }
    func style_updateSettingsButtonInsets(for traitCollection: UITraitCollection) {
        // style values
        let kImageInsetLeadingValue: CGFloat = 18
        let kLandscapeImagePhoneInsetLeadingValue: CGFloat = 24

        // ready to adjust the values
        let imageInsetLeadingValue: CGFloat
        let landscapeImagePhoneInsetLeadingValue: CGFloat

        // adjust the values based on orientation
        switch traitCollection.layoutDirection {
        case .rightToLeft:
            imageInsetLeadingValue = kImageInsetLeadingValue
            landscapeImagePhoneInsetLeadingValue = kLandscapeImagePhoneInsetLeadingValue
        case .leftToRight, .unspecified:
            fallthrough
        @unknown default:
            imageInsetLeadingValue = kImageInsetLeadingValue * -1
            landscapeImagePhoneInsetLeadingValue = kLandscapeImagePhoneInsetLeadingValue * -1
        }

        // reset the values to defaults
        self.imageInsets = .zero
        self.landscapeImagePhoneInsets = .zero

        // put in the new adjusted values
        self.imageInsets.left = imageInsetLeadingValue
        self.landscapeImagePhoneInsets.left = landscapeImagePhoneInsetLeadingValue
    }
}

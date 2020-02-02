//
//  UIView+WaterMe.swift
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

extension UIView {
    func maxCornerRadius(withDesiredRadius desiredRadius: CGFloat) -> CGFloat {
        let width = self.frame.width
        let height = self.frame.height
        let restrictingDimension = width < height ? width : height
        let halfRestrictingDimension = restrictingDimension / 2
        if halfRestrictingDimension > desiredRadius {
            return desiredRadius
        } else {
            return halfRestrictingDimension
        }
    }
}

extension UITraitCollection {
    @objc var userInterfaceStyleIsNormal: Bool {
        guard #available(iOS 12.0, *) else { return true }
        switch self.userInterfaceStyle {
        case .dark:
            return false
        case .light, .unspecified:
            fallthrough
        @unknown default:
            return true
        }
    }
}

//
//  DragAndDropPlayerManager+UIKit.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2020/01/30.
//  Copyright © 2020 Saturday Apps. All rights reserved.
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

extension DragAndDropPlayerManager {
    func setTraitCollection(_ newValue: UITraitCollection) {

        let verticalSizeClassIsDefault: Bool
        switch newValue.verticalSizeClass {
        case .compact:
            verticalSizeClassIsDefault = false
        case .regular, .unspecified:
            fallthrough
        @unknown default:
            verticalSizeClassIsDefault = true
        }

        let userInterfaceStyleIsDefault = newValue.userInterfaceStyleIsNormal

        self.updateVideoAssets(landscape: verticalSizeClassIsDefault,
                               darkMode: !userInterfaceStyleIsDefault)
    }
}

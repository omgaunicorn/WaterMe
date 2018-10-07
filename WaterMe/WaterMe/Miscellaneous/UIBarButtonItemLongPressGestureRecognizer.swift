//
//  UIBarButtonItemLongPressGestureRecognizer.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/6/18.
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

class UIBarButtonItemLongPressGestureRecognizer: UILongPressGestureRecognizer {

    init?(barButtonItem: UIBarButtonItem, target: Any, action: Selector) {
        guard let view = barButtonItem.value(forKey: "_view") as? UIView else { return nil }
        super.init(target: target, action: action)
        view.addGestureRecognizer(self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        //
        // If accessibility sizes are enabled, then tapping and holding on the BBI.
        // Causes a zoomed UI to popup so the user can read it.
        // This gesture recognizer breaks this important accessibility feature of iOS.
        // So when accessibility text sizes are enabled, the gesture recognizer
        // will be forcefully cancelled.
        //
        let isAccessible = self.view?.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ?? false
        guard isAccessible else { return }
        self.state = .cancelled
    }

}

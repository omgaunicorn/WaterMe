//
//  ReminderVesselIconButton.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/5/17.
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

import WaterMeData
import UIKit

class ReminderVesselIconButton: UIButton {
    
    enum Size {
        case small, large
        func attributedString(with string: String, accessibilityFontSizeEnabled: Bool) -> NSAttributedString {
            switch self {
            case .small:
                return NSAttributedString(string: string, style: Style.emojiSmallDisplay(accessibilityFontSizeEnabled: accessibilityFontSizeEnabled))
            case .large:
                return NSAttributedString(string: string, style: Style.emojiLargeDisplay(accessibilityFontSizeEnabled: accessibilityFontSizeEnabled))
            }
        }
    }
    var size: Size = .large
    private var currentIcon: ReminderVessel.Icon?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView?.contentMode = .scaleAspectFit
        self.setAttributedTitle(nil, for: .normal)
        self.setImage(nil, for: .normal)
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
    }
    
    func setIcon(_ icon: ReminderVessel.Icon?, for controlState: UIControlState = .normal) {
        self.currentIcon = icon
        guard let icon = icon else {
            self.setAttributedTitle(nil, for: .normal)
            self.setImage(nil, for: .normal)
            return
        }
        
        let accessibility = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        switch icon {
        case .emoji(let string):
            self.setImage(nil, for: controlState)
            self.setAttributedTitle(self.size.attributedString(with: string, accessibilityFontSizeEnabled: accessibility), for: controlState)
        case .image(let image):
            self.setImage(image, for: controlState)
            self.setAttributedTitle(nil, for: controlState)
        }
    }
    
    func setKind(_ kind: Reminder.Kind?, for controlState: UIControlState = .normal) {
        guard let kind = kind else {
            self.setAttributedTitle(nil, for: .normal)
            self.setImage(nil, for: .normal)
            return
        }
        fatalError("TODO: Make this into two subclasses. 1 for reminderKind and 1 for icon")
        let accessibility = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        let string: NSAttributedString
        switch kind {
        case .water:
            string = self.size.attributedString(with: "💦", accessibilityFontSizeEnabled: accessibility)
        case .fertilize:
            string = self.size.attributedString(with: "🎩", accessibilityFontSizeEnabled: accessibility)
        case .move:
            string = self.size.attributedString(with: "🔄", accessibilityFontSizeEnabled: accessibility)
        case .other:
            string = self.size.attributedString(with: "❓", accessibilityFontSizeEnabled: accessibility)
        }
        self.setAttributedTitle(string, for: .normal)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setIcon(self.currentIcon)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch self.size {
        case .small:
            self.layer.borderWidth = 0
            self.layer.borderColor = nil
            self.layer.cornerRadius = 0
        case .large:
            self.layer.borderWidth = 2
            self.layer.borderColor = self.tintColor.cgColor
            self.layer.cornerRadius = floor(self.bounds.width / 2)
        }
    }
    
}

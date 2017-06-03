//
//  StyleExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import WaterMeData
import UIKit

extension UIButton {
    func style_reminderVesselIconButton() {
        self.titleLabel?.style_emojiDisplayLabel()
        self.setTitle(nil, for: .normal)
        self.isUserInteractionEnabled = false
    }
    func setIcon(_ icon: ReminderVessel.Icon?, for controlState: UIControlState = .normal) {
        guard let icon = icon else {
            self.setTitle(nil, for: .normal)
            self.setImage(nil, for: .normal)
            return
        }
        
        switch icon {
        case .emoji(let string):
            self.setTitle(string, for: controlState)
        case .image(let data):
            break
        }
    }
}

extension UILabel {
    func style_reminderVesselNameLabel() {
        self.adjustsFontForContentSizeCategory = true
        self.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    func style_emojiDisplayLabel() {
        self.font = UIFont.systemFont(ofSize: 60)
        self.lineBreakMode = .byClipping
        self.clipsToBounds = true
    }
}

extension UITextField {
    func style_bodyFontTextField() {
        self.adjustsFontForContentSizeCategory = true
        self.font = UIFont.preferredFont(forTextStyle: .body)
    }
}

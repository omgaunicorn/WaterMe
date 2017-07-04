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
    }
    var size: Size = .large { didSet { self.updateSize() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateSize()
        self.imageView?.contentMode = .scaleAspectFit
        self.setTitle(nil, for: .normal)
        self.setImage(nil, for: .normal)
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
    }
    
    private func updateSize() {
        switch self.size {
        case .small:
            self.titleLabel?.style_emojiSmallDisplayLabel()
        case .large:
            self.titleLabel?.style_emojiLargeDisplayLabel()
        }
        self.setNeedsLayout()
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
    
    func setIcon(_ icon: ReminderVessel.Icon?, for controlState: UIControlState = .normal) {
        guard let icon = icon else {
            self.setTitle(nil, for: .normal)
            self.setImage(nil, for: .normal)
            return
        }
        
        switch icon {
        case .emoji(let string):
            self.setImage(nil, for: controlState)
            self.setTitle(string, for: controlState)
        case .image(let image):
            self.setTitle(nil, for: controlState)
            self.setImage(image, for: controlState)
        }
    }
    
    func setKind(_ kind: Reminder.Kind?, for controlState: UIControlState = .normal) {
        guard let kind = kind else {
            self.setTitle(nil, for: .normal)
            self.setImage(nil, for: .normal)
            return
        }
        switch kind {
        case .water:
            self.setTitle("💦", for: .normal)
        case .fertilize:
            self.setTitle("🎩", for: .normal)
        case .move:
            self.setTitle("🔄", for: .normal)
        case .other:
            self.setTitle("❓", for: .normal)
        }
    }
    
}

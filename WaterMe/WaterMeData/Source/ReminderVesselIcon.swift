//
//  ReminderVesselIcon.swift
//  Pods
//
//  Created by Jeffrey Bergier on 6/4/17.
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

import UIKit

fileprivate extension UIImage {
    fileprivate func cropping(to size: CGSize) -> UIImage {
        var size = size
        size.width *= self.scale
        size.height *= self.scale
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    fileprivate func dataNoLarger(than max: Int) {
        
    }
}

public extension ReminderVessel {
    
    public enum Icon {
        case emoji(String), image(UIImage)
        
        public init(emojiString: String) {
            self = .emoji(emojiString)
        }
        
        public init(rawImage: UIImage) {
            let size = CGSize(width: 640, height: 640)
            let cropped = rawImage.cropping(to: size)
            self = .image(cropped)
        }
    }
    
}

internal extension ReminderVessel.Icon {
    
    internal init(rawImageData: Data?, emojiString: String?) {
        self = .emoji("X")
    }
    
    internal var dataValue: Data? {
        switch self {
        case .emoji:
            return nil
        case .image(let image):
            return nil
        }
    }
    
    internal var stringValue: String? {
        switch self {
        case .emoji(let string):
            return string
        case .image:
            return nil
        }
    }
    
}

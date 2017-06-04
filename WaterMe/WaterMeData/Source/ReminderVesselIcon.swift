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

public extension ReminderVessel {
    
    public enum Icon {
        case emoji(String), image(UIImage)
        
        public init(rawImage: UIImage) {
            let size = rawImage.maxSize
            let cropped = rawImage.cropping(to: size)
            self = .image(cropped)
        }
    }
    
}

internal extension ReminderVessel.Icon {
    
    internal init(rawImageData: Data?, emojiString: String?) {
        if let data = rawImageData, let image = UIImage(data: data) {
            self = .image(image)
        } else if let emojiString = emojiString {
            self = .emoji(emojiString)
        } else {
            self = .emoji("☠")
        }
    }
    
    internal var dataValue: Data? {
        switch self {
        case .emoji:
            return nil
        case .image(let image):
            let data = image.dataNoLarger(than: 40000)
            return data
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

fileprivate extension UIImage {
    
    fileprivate var maxSize: CGSize {
        let max: CGFloat = 640
        let widthLess = self.size.width < max
        let heightLess = self.size.height < max
        if widthLess || heightLess {
            if self.size.width < self.size.height {
                return CGSize(width: self.size.width, height: self.size.width)
            } else {
                return CGSize(width: self.size.height, height: self.size.height)
            }
        } else {
            return CGSize(width: max, height: max)
        }
    }
    
    fileprivate func cropping(to size: CGSize) -> UIImage {
        var size = size
        size.width *= self.scale
        size.height *= self.scale
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    fileprivate func dataNoLarger(than max: Int) -> Data? {
        var compression: CGFloat = 0.5
        var compressedData: Data?
        while compressedData == nil && compression >= 0 {
            let _data = UIImageJPEGRepresentation(self, compression)
            compression -= 0.1
            guard let data = _data, data.count < max else { continue }
            compressedData = data
        }
        return compressedData
    }
}

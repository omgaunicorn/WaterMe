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

        internal init?(rawImage: UIImage?, emojiString: String?) {
            if let emoji = emojiString {
                // self = .emoji(emoji) // produced an error
                self.init(emojiString: emoji)
            } else if let image = rawImage {
                self.init(rawImage: image)
            } else {
                return nil
            }
        }

        // Hack: Needed just for the initializer above. Otherwise it produced an error.
        // self used before self.init
        private init(emojiString: String) {
            self = .emoji(emojiString)
        }
        
        public init(rawImage: UIImage) {
            // all of this code assumes we're cropping to square image
            // it also assumes that we're converting it to a new image with a scale of 1
            let smallestDimension = rawImage.size.width > rawImage.size.height ? rawImage.size.height : rawImage.size.width
            let smallestScaledDimension = smallestDimension * rawImage.scale
            let originalSquareSize = CGSize(width: smallestScaledDimension, height: smallestScaledDimension)
            let cropped = rawImage.cropping(to: originalSquareSize)
            let max = UIImage.style_maxSize
            let reducedSize = originalSquareSize.width > max ? CGSize(width: max, height: max) : originalSquareSize
            let resized = cropped.resize(toTargetSize: reducedSize)
            self = .image(resized)
        }
    }
    
}

internal extension ReminderVessel.Icon {
    
    internal init?(rawImageData: Data?, emojiString: String?) {
        if let data = rawImageData, let image = UIImage(data: data) {
            self = .image(image)
        } else if let emojiString = emojiString {
            self = .emoji(emojiString)
        } else {
            return nil
        }
    }
    
    internal var dataValue: Data? {
        switch self {
        case .emoji:
            return nil
        case .image(let image):
            let data = image.dataNoLarger(than: 50000)
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

    fileprivate static let style_maxSize: CGFloat = 500
    fileprivate static let style_scale: CGFloat = 1

    fileprivate func cropping(to size: CGSize) -> UIImage {
        var size = size
        size.width *= self.scale
        size.height *= self.scale

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    fileprivate func resize(toTargetSize targetSize: CGSize) -> UIImage {
        // inspired by Hamptin Catlin
        // https://gist.github.com/licvido/55d12a8eb76a8103c753

        let newScale = type(of: self).style_scale
        let originalSize = self.size

        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height

        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
        } else {
            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)

        // Actually do the resizing to the rect using the ImageContext stuff
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        format.opaque = true
        let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image() { _ in
            self.draw(in: rect)
        }

        return newImage
    }
    
    fileprivate func dataNoLarger(than max: Int) -> Data? {
        var compression: CGFloat = 0.5
        var compressedData: Data?
        while compressedData == nil && compression >= 0 {
            let _data = self.jpegData(compressionQuality: compression)
            compression -= 0.1
            guard let data = _data, data.count < max else { continue }
            compressedData = data
        }
        let message = "Image couldn't be compressed to fit: \(max) bytes"
        log.error(message)
        assert(compressedData != nil, message)
        return compressedData
    }
}

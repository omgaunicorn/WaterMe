//
//  ImageEmojiObject.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 29/12/17.
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

class ImageEmojiObject: NSObject, NSCoding {

    static let PlantEmojiImageKey = "PlantEmojiImageKey"
    static let PlantEmojiStringKey = "PlantEmojiStringKey"

    let emojiImage: UIImage?
    let emojiString: String?

    required init?(coder decoder: NSCoder) {
        let emojiImage = decoder.decodeObject(forKey: type(of: self).PlantEmojiImageKey) as? UIImage
        let emojiString = decoder.decodeObject(forKey: type(of: self).PlantEmojiStringKey) as? String

        self.emojiImage = emojiImage
        self.emojiString = emojiString

        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.emojiImage, forKey: type(of: self).PlantEmojiImageKey)
        coder.encode(self.emojiString, forKey: type(of: self).PlantEmojiStringKey)
    }
}

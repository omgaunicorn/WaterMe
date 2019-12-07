//
//  Color.swift
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

import WaterMeData
import UIKit

enum Color {
    static var textSecondary: UIColor {
        return .gray
    }
    static var textPrimary: UIColor {
        return .black
    }
    static var delete: UIColor {
        return .red
    }
    static var tint: UIColor {
        if UserDefaults.standard.increaseContrast == true {
            return darkTintColor
        } else {
            return UIColor(red: 200 / 255.0, green: 129 / 255.0, blue: 242 / 255.0, alpha: 1.0)
        }
    }
    static var darkTintColor: UIColor {
        return UIColor(red: 97 / 255.0, green: 46 / 255.0, blue: 128 / 255.0, alpha: 1.0)
    }
    static var genericBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    static var visuelEffectViewBackground: UIColor? {
        if UserDefaults.standard.increaseContrast == true {
            return nil
        } else {
            return tint.withAlphaComponent(0.25)
        }
    }
    static func color(for section: Reminder.Section) -> UIColor {
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        let a: CGFloat
        switch section {
        case .late:
            r = 221
            g = 158
            b = 95
            a = 1.0
        case .today, .tomorrow:
            r = 26
            g = 188
            b = 156
            a = 1.0
        case .thisWeek, .later:
            r = 200
            g = 129
            b = 242
            a = 1.0
        }
        let d: CGFloat = 255
        return UIColor(red: r / d, green: g / d, blue: b / d, alpha: a)
    }
}

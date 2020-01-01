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
        guard #available(iOS 13.0, *) else { return .gray }
        return .secondaryLabel
    }

    static var textPrimary: UIColor {
        guard #available(iOS 13.0, *) else { return .black }
        return .label
    }

    static var delete: UIColor {
        guard #available(iOS 13.0, *) else { return .red }
        return .systemRed
    }

    static var systemBackgroundColor: UIColor {
        guard #available(iOS 13.0, *) else { return .white }
        return .systemBackground
    }

    static var confetti1: UIColor {
        return _tint
    }

    static var confetti2: UIColor {
        return _increasedContrastTint
    }

    static var tint: UIColor {
        if UserDefaults.standard.increaseContrast == true {
            return _increasedContrastTint
        } else {
            return _tint
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
        switch section {
        case .late:
            return _late
        case .today:
            return _today
        case .tomorrow:
            return _tomorrow
        case .thisWeek:
            return _thisWeek
        case .later:
            return _later
        }
    }
}

extension Color {

    static private var _late: UIColor {
        return UIColor(red: 221 / 255.0, green: 158 / 255.0, blue: 95 / 255.0, alpha: 1.0)
    }

    static private var _today: UIColor {
        return _tomorrow
    }

    static private var _tomorrow: UIColor {
        return UIColor(red: 26 / 255.0, green: 188 / 255.0, blue: 156 / 255.0, alpha: 1.0)
    }

    static private var _thisWeek: UIColor {
        return _later
    }

    static private var _later: UIColor {
        return UIColor(red: 200 / 255.0, green: 129 / 255.0, blue: 242 / 255.0, alpha: 1.0)
    }

    static private var _tint: UIColor {
        return UIColor(red: 200 / 255.0, green: 129 / 255.0, blue: 242 / 255.0, alpha: 1.0)
    }

    static private var _increasedContrastTint: UIColor {
        return UIColor(red: 97 / 255.0, green: 46 / 255.0, blue: 128 / 255.0, alpha: 1.0)
    }
}

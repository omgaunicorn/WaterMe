//
//  StyleExtensions.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/3/17.
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

extension UITableViewCell {
    static let style_labelCellTopPadding: CGFloat = 12
    static let style_labelCellBottomPadding: CGFloat = 10
    static let style_labelCellLeadingPadding: CGFloat = 20
    static let style_labelCellTrailingPadding: CGFloat = 20
    
    static let style_textFieldCellTopPadding: CGFloat = 8
    static let style_textFieldCellBottomPadding: CGFloat = 6
    static let style_textFieldCellLeadingPadding: CGFloat = 20
    static let style_textFieldCellTrailingPadding: CGFloat = 20
}

enum Style {
    case selectableTableViewCell
    case readOnlyTableViewCell
    case textInputTableViewCell
    case emojiSmallDisplay
    case emojiLargeDisplay
    case reminderVesselCollectionViewCell
    var attributes: [NSAttributedStringKey : Any] {
        switch self {
        case .reminderVesselCollectionViewCell:
            return [
                NSAttributedStringKey.font : Font.bodyPlus,
                NSAttributedStringKey.foregroundColor : Color.textPrimary
            ]
        case .emojiSmallDisplay:
            return [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 32),
                NSAttributedStringKey.foregroundColor : Color.textPrimary
            ]
        case .emojiLargeDisplay:
            return [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 60),
                NSAttributedStringKey.foregroundColor : Color.textPrimary
            ]
        case .textInputTableViewCell:
            return [
                NSAttributedStringKey.font : Font.body,
                NSAttributedStringKey.foregroundColor : Color.textPrimary
            ]
        case .readOnlyTableViewCell:
            return [
                NSAttributedStringKey.font : Font.bodyMinus,
                NSAttributedStringKey.foregroundColor : Color.textSecondary
            ]
        case .selectableTableViewCell:
            return [
                NSAttributedStringKey.font : Font.bodyMinus,
                NSAttributedStringKey.foregroundColor : Color.textPrimary
            ]
        }
    }
    
    private enum Font {
        static var bodyPlus: UIFont {
            return UIFont.preferredFont(forTextStyle: .title3)
        }
        static var body: UIFont {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        static var bodyMinus: UIFont {
            return UIFont.preferredFont(forTextStyle: .callout)
        }
    }
    
    private enum Color {
        static var textSecondary: UIColor {
            return .gray
        }
        static var textPrimary: UIColor {
            return .black
        }
    }
}

extension NSAttributedString {
    convenience init(string: String, style: Style, withTintColorFromView view: UIView? = nil) {
        var attributes = style.attributes
        if let view = view {
            attributes[NSAttributedStringKey.foregroundColor] = view.tintColor
        }
        self.init(string: string, attributes: attributes)
    }
}

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

extension ReminderCollectionViewCell {
    static let style_emojiImageViewWidth: CGFloat = 100
    static let style_emojiImageViewWidthAccessibility: CGFloat = 170
    static let style_dragAndDropPreviewCornerRadius: CGFloat = 8
}

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

extension TextViewTableViewCell {
    static let style_cellHeightAccessibilityTextSizeEnabled: CGFloat = 400
    static let style_cellHeightAccessibilityTextSizeDisabled: CGFloat = 200
}

extension ReminderVesselIconTableViewCell {
    static let style_iconButtonHeightAccessibilityTextSizeEnabled: CGFloat = 280
    static let style_iconButtonHeightAccessibilityTextSizeDisabled: CGFloat = 140
}

extension UICollectionReusableView {
    static let style_backgroundViewCornerRadius: CGFloat = 6
    static let style_sectionHeaderBackgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
}

enum Style {

    static let centerStyle: NSParagraphStyle = {
        let p = NSMutableParagraphStyle()
        p.alignment = .center
        // swiftlint:disable:next force_cast
        return p.copy() as! NSParagraphStyle
    }()

    case sectionHeader
    case selectableTableViewCell
    case selectableTableViewCellDisabled
    case selectableTableViewCellHelper
    case readOnlyTableViewCell
    case textInputTableViewCell
    case emojiSuperSmall
    case emojiSmall(accessibilityFontSizeEnabled: Bool)
    case emojiLarge(accessibilityFontSizeEnabled: Bool)
    case reminderVesselDragPreviewViewPrimary
    case reminderVesselDragPreviewViewPrimaryDisabled
    case reminderVesselDragPreviewViewSecondary
    case reminderVesselCollectionViewCellPrimary
    case reminderVesselCollectionViewCellPrimaryDisabled
    case reminderVesselCollectionViewCellSecondary
    var attributes: [NSAttributedStringKey : Any] {
        switch self {
        case .reminderVesselCollectionViewCellPrimary:
            return [
                .font : Font.bodyPlus,
                .foregroundColor : Color.textPrimary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderVesselCollectionViewCellPrimaryDisabled:
            return [
                .font : Font.bodyPlus,
                .foregroundColor : Color.textSecondary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderVesselDragPreviewViewPrimary:
            return [
                .font : Font.bodyIgnoringDynamicType,
                .foregroundColor : Color.textPrimary
            ]
        case .reminderVesselDragPreviewViewPrimaryDisabled:
            return [
                .font : Font.bodyIgnoringDynamicType,
                .foregroundColor : Color.textSecondary
            ]
        case .emojiSuperSmall:
            return [
                .font : UIFont.systemFont(ofSize: 20)
            ]
        case .emojiSmall(let accessibilityFontSizeEnabled):
            return [
                .font : UIFont.systemFont(ofSize: accessibilityFontSizeEnabled ? 50 : 36)
            ]
        case .emojiLarge(let accessibilityFontSizeEnabled):
            return [
                .font : UIFont.systemFont(ofSize: accessibilityFontSizeEnabled ? 120 : 60)
            ]
        case .textInputTableViewCell:
            return [
                .font : Font.body,
                .foregroundColor : Color.textPrimary
            ]
        case .readOnlyTableViewCell:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textSecondary
            ]
        case .selectableTableViewCell:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textPrimary
            ]
        case .selectableTableViewCellDisabled:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textSecondary
            ]
        case .selectableTableViewCellHelper:
            return [
                .font : Font.bodyMinusBold,
                .foregroundColor : Color.textSecondary
            ]
        case .reminderVesselCollectionViewCellSecondary:
            var x = type(of: self).selectableTableViewCell.attributes
            x[.paragraphStyle] = type(of: self).centerStyle
            return x
        case .reminderVesselDragPreviewViewSecondary:
            return [
                .font : Font.bodyMinusIgnoringDynamicType,
                .foregroundColor : Color.textPrimary
            ]
        case .sectionHeader:
            return type(of: self).selectableTableViewCell.attributes
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
        static var bodyMinusBold: UIFont {
            return UIFont.preferredFont(forTextStyle: .subheadline)
        }
        static var bodyIgnoringDynamicType: UIFont {
            return UIFont.systemFont(ofSize: 18)
        }
        static var bodyMinusIgnoringDynamicType: UIFont {
            return UIFont.systemFont(ofSize: 14)
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
    
    func appending(_ rhs: NSAttributedString) -> NSAttributedString {
        let lhs = NSMutableAttributedString(attributedString: self)
        lhs.append(rhs)
        let appended = NSAttributedString(attributedString: lhs)
        return appended
    }
    
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        return lhs.appending(rhs)
    }
}

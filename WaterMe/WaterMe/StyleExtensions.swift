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

import CropViewController
import WaterMeData
import UIKit

extension ModalParentViewController {
    enum Style {
        static let grayViewColor = UIColor.black.withAlphaComponent(0.5)
    }
}

extension ReminderVessel {
    var shortLabelSafeDisplayName: String? {
        let name = self.displayName ?? ""
        let characterLimit = 20
        guard name.count > characterLimit else { return self.displayName }
        let endIndex = name.index(name.startIndex, offsetBy: characterLimit)
        let substring = String(self.displayName![..<endIndex])
        if let trimmed = substring.leadingTrailingWhiteSpaceTrimmedNonEmptyString {
            return trimmed + "…"
        } else {
            return nil
        }
    }
}

extension UIApplication {
    static let style_animationDurationLong: TimeInterval = 1.2
    static let style_animationDurationNormal: TimeInterval = 0.3
    static let style_cornerRadius: CGFloat = 8
    class func style_configure() {
        UIView.appearance().tintColor = Style.Color.tint
        UIView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = nil
        UIImageView.appearance(whenContainedInInstancesOf: [ReminderTableViewCell.self]).tintColor = Style.Color.textSecondary
        UIVisualEffectView.appearance(whenContainedInInstancesOf: [CropViewController.self]).backgroundColor = nil
        UIVisualEffectView.appearance().backgroundColor = Style.Color.visuelEffectViewBackground
    }
}

extension DragTargetInstructionalView {
    static let style_animationDurationLong: TimeInterval = 2
    static let style_animationDurationNormal: TimeInterval = 1
    static let style_animationDelayLong: TimeInterval = 4
    static let style_animationDelayNormal: TimeInterval = 1
}

extension ReminderFinishDropTargetViewController {
    static let style_dropTargetViewCompactHeight: CGFloat = 88
    static let style_dropTargetViewCompactHeightAccessibilityTextSizeEnabled: CGFloat = 132
}

extension ReminderCollectionViewCell {
    static let style_emojiImageViewWidth: CGFloat = 100
    static let style_emojiImageViewWidthAccessibility: CGFloat = 170
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
}

enum Style {

    static let centerStyle: NSParagraphStyle = {
        // swiftlint:disable:next force_cast
        let p = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        p.alignment = .center
        p.lineBreakMode = .byTruncatingMiddle
        // swiftlint:disable:next force_cast
        return p.copy() as! NSParagraphStyle
    }()

    case sectionHeader(Reminder.Section)
    case selectableTableViewCell
    case selectableTableViewCellDisabled
    case selectableTableViewCellHelper
    case readOnlyTableViewCell
    case textInputTableViewCell
    case migratorTitle
    case migratorSubtitle
    case migratorBody
    case migratorBodySmall
    case migratorPrimaryButton
    case migratorSecondaryButton
    case emojiSuperSmall
    case emojiSmall(accessibilityFontSizeEnabled: Bool)
    case emojiLarge(accessibilityFontSizeEnabled: Bool)
    case reminderVesselDragPreviewViewPrimary
    case reminderVesselDragPreviewViewPrimaryDisabled
    case reminderVesselDragPreviewViewSecondary
    case reminderVesselCollectionViewCellPrimary(UIColor?)
    case reminderVesselCollectionViewCellPrimaryDisabled
    case reminderVesselCollectionViewCellSecondary
    case dragInstructionalText(UIColor)
    var attributes: [NSAttributedStringKey : Any] {
        switch self {
        case .migratorTitle:
            return [
                .font : Font.bodyPlusPlusPlus,
                .foregroundColor : Color.textPrimary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .migratorSubtitle:
            return [
                .font : Font.bodyPlusBold,
                .foregroundColor : Color.textPrimary,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .migratorBody:
            return [
                .font : Font.body,
                .foregroundColor : Color.textPrimary
            ]
        case .migratorBodySmall:
            return [
                .font : Font.bodyMinus,
                .foregroundColor : Color.textPrimary
            ]
        case .migratorPrimaryButton:
            return [
                .font : Font.bodyPlusPlus
            ]
        case .migratorSecondaryButton:
            return [
                .font : Font.body
            ]
        case .dragInstructionalText(let color):
            return [
                .font : Font.bodyPlusPlus,
                .foregroundColor : color,
                .paragraphStyle : type(of: self).centerStyle
            ]
        case .reminderVesselCollectionViewCellPrimary(let color):
            return [
                .font : Font.bodyPlus,
                .foregroundColor : color ?? Color.textPrimary,
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
                .font : Font.emojiFont(ofSize: accessibilityFontSizeEnabled ? 50 : 36),
                .baselineOffset : NSNumber(value: accessibilityFontSizeEnabled ? -8 : -4)
            ]
        case .emojiLarge(let accessibilityFontSizeEnabled):
            return [
                .font : Font.emojiFont(ofSize: accessibilityFontSizeEnabled ? 120 : 60),
                .baselineOffset : NSNumber(value: accessibilityFontSizeEnabled ? -10 : -5)
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
        case .sectionHeader(let section):
            return [
                .font : Font.bodyPlusBold,
                .foregroundColor : Color.color(for: section)
            ]
        }
    }
    
    private enum Font {
        static var bodyPlusPlusPlus: UIFont {
            return UIFont.preferredFont(forTextStyle: .title1)
        }
        static var bodyPlusPlus: UIFont {
            return UIFont.preferredFont(forTextStyle: .title2)
        }
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
        static var bodyPlusBold: UIFont {
            return UIFont.preferredFont(forTextStyle: .headline)
        }
        static var bodyIgnoringDynamicType: UIFont {
            return UIFont.systemFont(ofSize: 18)
        }
        static var bodyMinusIgnoringDynamicType: UIFont {
            return UIFont.systemFont(ofSize: 14)
        }
        static func emojiFont(ofSize size: CGFloat) -> UIFont {
            return UIFont(name: "AppleColorEmoj2", size: size)!
        }
    }
    
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
}

extension NSAttributedString {
    convenience init(string: String, style: Style) {
        self.init(string: string, attributes: style.attributes)
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

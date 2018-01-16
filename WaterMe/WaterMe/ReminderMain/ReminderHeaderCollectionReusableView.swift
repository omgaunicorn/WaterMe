//
//  ReminderHeaderCollectionReusableView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 20/10/17.
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

class ReminderHeaderCollectionReusableView: UICollectionReusableView {

    static let reuseID = "ReminderHeaderCollectionReusableView"
    static let kind = UICollectionElementKindSectionHeader
    class var nib: UINib { return UINib(nibName: self.reuseID, bundle: Bundle(for: self.self)) }

    @IBOutlet private weak var label: UILabel?
    @IBOutlet private weak var backgroundView: UIView?
    @IBOutlet private weak var colorView: UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView?.layer.cornerRadius = type(of: self).style_backgroundViewCornerRadius
    }

    func setSection(_ section: Reminder.Section) {
        self.label?.attributedText = NSAttributedString(string: section.localizedTitleString, style: .sectionHeader(section))
        self.colorView?.backgroundColor = Style.Color.color(for: section)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.bounds.height <= 2 {
            self.label?.alpha = 0
            self.backgroundView?.alpha = 0
        } else {
            self.label?.alpha = 1
            self.backgroundView?.alpha = 1
        }
    }
}

extension Reminder.Section {
    var localizedTitleString: String {
        switch self {
        case .late:
            return LocalizedString.late
        case .today:
            return LocalizedString.today
        case .tomorrow:
            return LocalizedString.tomorrow
        case .thisWeek:
            return LocalizedString.thisWeek
        case .later:
            return LocalizedString.later
        }
    }
}

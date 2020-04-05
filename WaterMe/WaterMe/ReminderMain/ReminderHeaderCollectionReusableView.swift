//
//  ReminderHeaderCollectionReusableView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 27/1/18.
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

class ReminderHeaderCollectionReusableView: BlurryBackgroundBottomLineCollectionReusableView {

    typealias SectionOrTint = Either<Reminder.Section, UIColor>

    override class var reuseID: String { return "ReminderHeaderCollectionReusableView" }
    override class var kind: String { return UICollectionView.elementKindSectionHeader }

    var section: Reminder.Section = .today {
        didSet {
            self.color = Color.color(for: section)
            self.updateText()
        }
    }

    private let label: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func commonInit() {
        super.commonInit()
        self.stackView.addArrangedSubview(self.label)
    }

    private func updateText() {
        let input: SectionOrTint = self.tintColor.isGray ? .right(self.tintColor) : .left(self.section)
        self.label.attributedText = NSAttributedString(string: self.section.localizedTitleString,
                                                       font: .sectionHeaderBold(input))
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.updateText()
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

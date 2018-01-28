//
//  EmojiPickerFooterCollectionReusableView.swift
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

class EmojiPickerFooterCollectionReusableView: BlurryBackgroundBottomLineCollectionReusableView {

    override class var reuseID: String { return "EmojiPickerFooterCollectionReusableView" }
    override class var kind: String { return UICollectionElementKindSectionFooter }

    var providedByButtonTapped: (() -> Void)?
    var whyButtonTapped: (() -> Void)?

    private let providedByLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let providedByButton: UIButton = {
        let v = UIButton()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func commonInit() {
        super.commonInit()

        // color the colorview
        self.colorView.backgroundColor = Style.Color.color(for: Reminder.Section.later)

        // add views to the stack view. This will get reset by trait collection changes
        self.stackView.addArrangedSubview(self.providedByLabel)
        self.stackView.addArrangedSubview(self.providedByButton)

        // configure labels
        self.providedByLabel.attributedText = NSAttributedString(string: "Emoji Provided by ", style: .sectionHeader(Reminder.Section.later))
        self.providedByButton.setAttributedTitle(NSAttributedString(string: "EmojiOne", style: .sectionHeader(Reminder.Section.today)), for: .normal)

        // configure targets
        self.providedByButton.addTarget(self, action: #selector(self.providedByButtonTapped(_:)), for: .touchUpInside)
    }

    @objc private func providedByButtonTapped(_ sender: Any) {
        self.providedByButtonTapped?()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.stackView.removeArrangedSubview(self.providedByButton)
        self.stackView.removeArrangedSubview(self.providedByLabel)
        switch self.traitCollection.layoutDirection {
        case .leftToRight, .unspecified:
            self.stackView.addArrangedSubview(self.providedByLabel)
            self.stackView.addArrangedSubview(self.providedByButton)
        case .rightToLeft:
            self.stackView.addArrangedSubview(self.providedByButton)
            self.stackView.addArrangedSubview(self.providedByLabel)
        }
    }
}

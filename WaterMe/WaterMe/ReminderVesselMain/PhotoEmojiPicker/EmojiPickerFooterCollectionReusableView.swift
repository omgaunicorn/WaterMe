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

    // to leading align the label
    private let spacerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
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

        // add views to the stack view.
        self.stackView.addArrangedSubview(self.providedByButton)
        self.stackView.addArrangedSubview(self.spacerView)

        // configure labels
        self.updateAttributedStrings()

        // configure targets
        self.providedByButton.addTarget(self, action: #selector(self.providedByButtonTapped(_:)), for: .touchUpInside)
    }

    private func updateAttributedStrings() {
        // color the colorview
        let primarySection = Reminder.Section.later
        self.colorView.backgroundColor = Color.color(for: primarySection)

        // configure labels
        let providedByString = NSAttributedString(stylingPrimaryString: LocalizedString.providedBy,
                                                  withPrimaryStyle: .sectionHeaderRegular(primarySection),
                                                  andSubString: LocalizedString.emojiOne,
                                                  withSubstringStyle: .sectionHeaderBold(Reminder.Section.today))
        self.providedByButton.setAttributedTitle(providedByString, for: .normal)
    }

    @objc private func providedByButtonTapped(_ sender: Any) {
        self.providedByButtonTapped?()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // configure labels
        self.updateAttributedStrings()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.providedByButtonTapped = nil
    }
}

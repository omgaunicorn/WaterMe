//
//  PurchaseThanksViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 14/1/18.
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

import Cheers
import WaterMeStore
import UIKit

extension PurchaseThanksViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("Thank You!",
                              comment: "Purchase Thanks: Title: A thank you to the user for supporting WaterMe via In-App Purchase.")
        static let subtitle =
            NSLocalizedString("In-App Purchase",
                              comment: "Purchase Thanks: Subtitle: Reminding the user what we're thanking them for.")
        static let body =
            NSLocalizedString("Thank you for your purchase. Your support is critical to the continued development of WaterMe.",
                              comment: "Purchase Thanks: Body: Body text thanking the user for their support.")
        
    }
}

class PurchaseThanksViewController: UIViewController {

    class func newVC(completion: @escaping PurchaseConfirmationCompletion) -> UIViewController {
        let sb = UIStoryboard(name: "PurchaseThanks", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ModalParentViewController
        vc.configureChild = { vc in
            // swiftlint:disable:next force_cast
            let vc = vc as! PurchaseThanksViewController
            vc.completionHandler = completion
        }
        return vc
    }

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var bodyLabel: UILabel?
    @IBOutlet private weak var reviewButton: UIButton?
    @IBOutlet private weak var cancelButton: UIButton?

    private var completionHandler: PurchaseConfirmationCompletion!
    private let cheerView: CheerView = {
        let v = CheerView()
        v.config.colors = [Style.Color.tint, Style.Color.tint, Style.Color.darkTintColor, Style.Color.darkTintColor]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.layer.cornerRadius = UIApplication.style_cornerRadius
        self.contentView.addSubview(self.cheerView)
        self.contentView.addConstraints([
            self.contentView.leadingAnchor.constraint(equalTo: self.cheerView.leadingAnchor, constant: 0),
            self.contentView.trailingAnchor.constraint(equalTo: self.cheerView.trailingAnchor, constant: 0),
            self.cheerView.heightAnchor.constraint(equalToConstant: 1)
            ])
        self.contentView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.transitionCoordinator!.animate(alongsideTransition: { _ in
            self.contentView.transform = CGAffineTransform.identity
        }, completion: { _ in
            self.cheerView.start()
            Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { _ in
                self.cheerView.stop()
            }
        })
    }

    private func configureAttributedText() {
        self.titleLabel?.attributedText = NSAttributedString(string: LocalizedString.title, style: .migratorTitle)
        self.subtitleLabel?.attributedText = NSAttributedString(string: LocalizedString.subtitle, style: .migratorSubtitle)
        self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.body, style: .migratorBody)
        self.reviewButton?.setAttributedTitle(NSAttributedString(string: SettingsMainViewController.LocalizedString.cellTitleTipJarFree, style: .migratorPrimaryButton), for: .normal)
        self.cancelButton?.setAttributedTitle(NSAttributedString(string: UIAlertController.LocalizedString.buttonTitleDismiss, style: .migratorSecondaryButton), for: .normal)
    }

    @IBAction private func reviewButtonTapped(_ sender: Any) {
        UIApplication.shared.openWriteReviewPage(completion: { _ in self.completionHandler(self) })
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        self.completionHandler(self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.configureAttributedText()
    }
}

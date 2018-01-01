//
//  CoreDataMigratorViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 29/12/17.
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

extension CoreDataMigratorViewController {
    enum LocalizedString {
        static let title =
            NSLocalizedString("WaterMe 2",
                              comment: "MigratorScreen: Title: Name of the app.")
        static let subtitle =
            NSLocalizedString("Data Migration",
                              comment: "MigratorScreen: Subtitle: Explains what is happening on the screen.")
        static let body =
            NSLocalizedString("In order to upgrade to WaterMe 2, a one time data migration is required.",
                              comment: "MigratorScreen: Body: Body text that explains the one time migration needed to upgrade to the new WaterMe.")
        static let bodyMigrating =
            NSLocalizedString("Migrating… Don't switch to a different app or lock the screen.",
                              comment: "MigratorScreen: Body: Body text that explains that the user should not lock the screen or switch apps until the migration is complete.")
        static let bodySuccess =
            NSLocalizedString("Success! Your plants have been migrated.",
                              comment: "MigratorScreen: Body: Body text that explains that the migration succeeded.")
        static let bodyFailure =
            NSLocalizedString("Oh no. A problem ocurred while migrating your plants.",
                              comment: "MigratorScreen: Body: Body text that explains that the migration failed.")
        static let migrateButtonTitle =
            NSLocalizedString("Start Migration",
                              comment: "MigratorScreen: Start Button Title: When the user clicks this button the migration starts.")
        static let migratingButtonTitle =
            NSLocalizedString("Migrating…",
                              comment: "MigratorScreen: Migrating Button Title: After the user starts the migration, the text of the button changes to this to show that migration is in progress.")
        static let cancelButtonTitle =
            NSLocalizedString("Skip for Now",
                              comment: "MigratorScreen: Cancel Button Title: When the user clicks this button the screen is dismissed and the migration does not happen, but next time the app is started, it will ask again.")
        static let doneButtonTitle =
            NSLocalizedString("Continue",
                              comment: "MigratorScreen: Done Button Title: After migrtion has failed or succeeded this button is shown to the user. When they tap it, it closes the migrator screen and brings them to the main app.")
        static let deleteButtonTitle =
            NSLocalizedString("Don't Migrate My Plants",
                              comment: "MigratorScreen: Delete Button Title: When the user clicks this button, the screen is dismissed and it will never appear again and they will not have access to their previous plants. This action is destructive.")
    }
}

class CoreDataMigratorViewController: UIViewController, HasBasicController {

    enum UIState {
        case launch, migrating, success, error
    }

    class func newVC(migrator: CoreDataMigratable, basicRC: BasicController, completion: @escaping (UIViewController, Bool) -> Void) -> UIViewController {
        let sb = UIStoryboard(name: "CoreDataMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! CoreDataMigratorViewController
        vc.completionHandler = completion
        vc.configure(with: basicRC)
        vc.migrator = migrator
        return vc
    }

    @IBOutlet private weak var contentView: UIView?
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel?
    @IBOutlet private weak var bodyLabel: UILabel?
    @IBOutlet private weak var progressView: UIProgressView?
    @IBOutlet private weak var migrateButton: UIButton?
    @IBOutlet private weak var cancelButton: UIButton?
    @IBOutlet private weak var deleteButton: UIButton?

    private var completionHandler: ((UIViewController, Bool) -> Void)!
    private var migrator: CoreDataMigratable!
    var basicRC: BasicController?
    private var state = UIState.launch {
        didSet {
            self.configureAttributedText()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentView?.layer.cornerRadius = UIApplication.style_cornerRadius
        self.progressView?.observedProgress = self.migrator.progress
    }

    private func configureAttributedText() {
        // set things to all defaults
        self.titleLabel?.attributedText = NSAttributedString(string: LocalizedString.title, style: .migratorTitle)
        self.subtitleLabel?.attributedText = NSAttributedString(string: LocalizedString.subtitle, style: .migratorSubtitle)
        self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.body, style: .migratorBody)
        self.migrateButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.migrateButtonTitle, style: .migratorPrimaryButton), for: .normal)
        self.cancelButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.cancelButtonTitle, style: .migratorSecondaryButton), for: .normal)
        self.deleteButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.deleteButtonTitle, style: .migratorSecondaryButton), for: .normal)
        self.progressView?.isHidden = false
        self.bodyLabel?.isHidden = false
        self.migrateButton?.alpha = 1
        self.migrateButton?.isHidden = false
        self.cancelButton?.isHidden = false
        self.deleteButton?.isHidden = false
        self.migrateButton?.isEnabled = true
        self.cancelButton?.isEnabled = true
        self.deleteButton?.isEnabled = true

        // customize things for each state
        let disableAlpha: CGFloat = 0.3
        switch self.state {
        case .launch:
            self.progressView?.isHidden = true
        case .migrating:
            self.migrateButton?.alpha = disableAlpha
            self.cancelButton?.isHidden = true
            self.deleteButton?.isHidden = true
            self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.bodyMigrating, style: .migratorBodySmall)
            self.migrateButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.migratingButtonTitle, style: .migratorPrimaryButton), for: .normal)
        case .success:
            self.progressView?.isHidden = true
            self.migrateButton?.isHidden = true
            self.deleteButton?.isHidden = true
            self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.bodySuccess, style: .migratorBody)
            self.cancelButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.doneButtonTitle, style: .migratorPrimaryButton), for: .normal)
        case .error:
            self.migrateButton?.isHidden = true
            self.deleteButton?.isHidden = true
            self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.bodyFailure, style: .migratorBody)
            self.cancelButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.doneButtonTitle, style: .migratorPrimaryButton), for: .normal)
        }
    }

    @IBAction private func migrateButtonTapped(_ sender: Any) {
        guard let basicRC = self.basicRC else {
            let message = "RealmController missing on a VC where this should not be possible."
            log.error(message)
            assertionFailure(message)
            self.completionHandler(self, false)
            return
        }
        // this VC could disappear while the migration is in progress
        // AND the VC does not own the migrator.
        // So it IS valid for the VC to be NIL while the migrator is working
        // So this weak self is required
        UIView.style_animateNormal({
            self.state = .migrating
        }, completion: { _ in
            UIApplication.shared.isIdleTimerDisabled = true
            self.migrator.start(with: basicRC) { [weak self] success in
                UIApplication.shared.isIdleTimerDisabled = false
                guard let welf = self else { return }
                UIView.style_animateNormal() {
                    welf.state = success ? .success : .error
                }
            }
        })
    }

    @IBAction private func cancelButtonTapped(_ sender: Any) {
        self.completionHandler(self, false)
    }

    @IBAction private func deleteButtonTapped(_ sender: Any) {

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.configureAttributedText()
    }

}

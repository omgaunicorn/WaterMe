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

class CoreDataMigratorViewController: UIViewController, HasBasicController {

    enum UIState {
        case launch, migrating, success, error
    }

    class func newVC(migrator: CoreDataMigratable, basicRC: BasicController, completion: @escaping (UIViewController, Bool) -> Void) -> UIViewController {
        let sb = UIStoryboard(name: "CoreDataMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ModalParentViewController
        vc.configureChild = { vc in
            // swiftlint:disable:next force_cast
            var vc = vc as! CoreDataMigratorViewController
            vc.completionHandler = completion
            vc.configure(with: basicRC)
            vc.migrator = migrator
        }
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
        self.contentView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.transitionCoordinator!.animate(alongsideTransition: { _ in
            self.contentView?.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    // swiftlint:disable:next function_body_length
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
        self.migrateButton?.alpha = 0 // setting alpha to 0 improves animations
        self.cancelButton?.alpha = 0
        self.deleteButton?.alpha = 0
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
            self.migrateButton?.alpha = 1
            self.cancelButton?.alpha = 1
            self.deleteButton?.alpha = 1
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
            self.cancelButton?.alpha = 1
            self.bodyLabel?.attributedText = NSAttributedString(string: LocalizedString.bodySuccess, style: .migratorBody)
            self.cancelButton?.setAttributedTitle(NSAttributedString(string: LocalizedString.doneButtonTitle, style: .migratorPrimaryButton), for: .normal)
        case .error:
            self.cancelButton?.alpha = 1
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
        self.migrator.deleteCoreDataStoreWithoutMigrating()
        self.completionHandler(self, false)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.configureAttributedText()
    }

}

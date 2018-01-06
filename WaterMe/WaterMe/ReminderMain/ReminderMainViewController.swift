//
//  ReminderMainViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 8/21/17.
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

class ReminderMainViewController: UIViewController, HasProController, HasBasicController {
    
    class func newVC(basicController: BasicController?, proController: ProController? = nil) -> UINavigationController {
        let sb = UIStoryboard(name: "ReminderMain", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderMainViewController
        vc.title = AppDelegate.LocalizedString.appTitle // set here because it works better in UITabBarController
        vc.configure(with: basicController)
        vc.configure(with: proController)
        return navVC
    }

    private weak var collectionVC: ReminderCollectionViewController?
    private weak var dropTargetViewController: ReminderFinishDropTargetViewController?

    private lazy var plantsBBI: UIBarButtonItem = UIBarButtonItem(title: ReminderVesselMainViewController.LocalizedString.title, style: .done, target: self, action: #selector(self.plantsButtonTapped(_:)))
    private lazy var settingsBBI: UIBarButtonItem = UIBarButtonItem(title: SettingsMainViewController.LocalizedString.title, style: .plain, target: self, action: #selector(self.settingsButtonTapped(_:)))
    
    var basicRC: BasicController?
    var proRC: ProController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // configure toolbar buttons
        self.navigationItem.rightBarButtonItem = self.plantsBBI
        self.navigationItem.leftBarButtonItem = self.settingsBBI

        self.collectionVC?.delegate = self
        // custom behavior needed here, otherwise it only automatically adjusts along the scrolling direction
        // we need it to automatically adjust in both axes
        self.collectionVC?.collectionView?.contentInsetAdjustmentBehavior = .always
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let error = self.collectionVC?.reminders?.lastError {
            self.collectionVC?.reminders?.lastError = nil
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
        } else if let migrator = AppDelegate.shared.coreDataMigrator, let basicRC = self.basicRC {
            let vc = CoreDataMigratorViewController.newVC(migrator: migrator, basicRC: basicRC) { vc, _ in
                AppDelegate.shared.coreDataMigrator = nil
                vc.dismiss(animated: true, completion: nil)
            }
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction private func plantsButtonTapped(_ sender: Any) {
        let vc = ReminderVesselMainViewController.newVC(basicController: self.basicRC, proController: self.proRC) { vc in
            vc.dismiss(animated: true, completion: nil)
        }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction private func settingsButtonTapped(_ sender: Any) {

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // if dropTargetViewController it causes the collectionview insets to be updated
        if self.dropTargetViewController == nil {
            self.updateCollectionViewInsets()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        // if dropTargetViewController it causes the collectionview insets to be updated
        if self.dropTargetViewController == nil {
            self.updateCollectionViewInsets()
        }
    }

    private func updateCollectionViewInsets() {
        let customInset: UIEdgeInsets
        switch self.traitCollection.verticalSizeClass {
        case .regular, .unspecified:
            // get the width and set the custom inset
            let dragViewHeight = self.dropTargetViewController?.dropTargetViewHeight ?? 0
            customInset = UIEdgeInsets(top: dragViewHeight, left: 0, bottom: 0, right: 0)
            // we need custom scroll insets in portrait
            self.collectionVC?.collectionView?.scrollIndicatorInsets = customInset
        case .compact:
            // Scroll Indicators can have normal behavior in landscape
            self.collectionVC?.collectionView?.scrollIndicatorInsets = .zero
            // get the width and set the custom inset
            let dragViewWidth = self.dropTargetViewController?.view.bounds.width ?? 0
            customInset = UIEdgeInsets(top: 0, left: dragViewWidth, bottom: 0, right: 0)
        }
        self.collectionVC?.collectionView?.contentInset = customInset
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var hasBasic = segue.destination as? HasBasicController
        hasBasic?.configure(with: self.basicRC)
        var hasPro = segue.destination as? HasProController
        hasPro?.configure(with: self.proRC)

        if let destVC = segue.destination as? ReminderCollectionViewController {
            self.collectionVC = destVC
        } else if let destVC = segue.destination as? ReminderFinishDropTargetViewController {
            destVC.delegate = self
            self.dropTargetViewController = destVC
        }
    }
}

extension ReminderMainViewController: ReminderFinishDropTargetViewControllerDelegate {
    func animateAlongSideDropTargetViewResize(within: ReminderFinishDropTargetViewController) -> (() -> Void)? {
        return { self.updateCollectionViewInsets() }
    }
}

extension ReminderMainViewController: ReminderCollectionViewControllerDelegate {

    func dragSessionWillBegin(_ session: UIDragSession, within viewController: ReminderCollectionViewController) {
        self.settingsBBI.isEnabled = false
        self.plantsBBI.isEnabled = false
    }
    
    func dragSessionDidEnd(_ session: UIDragSession, within viewController: ReminderCollectionViewController) {
        self.settingsBBI.isEnabled = true
        self.plantsBBI.isEnabled = true
    }

    // swiftlint:disable:next function_parameter_count
    func userDidSelectReminder(with identifier: Reminder.Identifier,
                               of kind: Reminder.Kind,
                               withNote note: String?,
                               from view: UIView,
                               deselectAnimated: @escaping (Bool) -> Void,
                               within viewController: ReminderCollectionViewController)
    {
        guard let basicRC = self.basicRC else { assertionFailure("Missing Realm Controller"); return; }
        let alert = UIAlertController(title: kind.stringValue, message: note, preferredStyle: .actionSheet)
        
        // configure popover presentation for ipad
        // popoverPresentationController is NIL on iPhones
        alert.popoverPresentationController?.sourceView = view
        let origin = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        alert.popoverPresentationController?.sourceRect = CGRect(origin: origin, size: .zero)
        alert.popoverPresentationController?.permittedArrowDirections = [.up, .down]

        // configure the alert to show
        let editReminder = UIAlertAction(title: LocalizedString.buttonTitleReminderEdit, style: .default) { _ in
            let result = basicRC.reminder(matching: identifier)
            switch result {
            case .success(let reminder):
                let vc = ReminderEditViewController.newVC(basicController: self.basicRC, purpose: .existing(reminder)) { vc in
                    vc.dismiss(animated: true, completion: { deselectAnimated(true) })
                }
                self.present(vc, animated: true, completion: nil)
            case .failure(let error):
                deselectAnimated(true)
                self.present(UIAlertController(error: error, completion: nil), animated: true, completion: nil)
            }
        }
        let editVessel = UIAlertAction(title: LocalizedString.buttonTitleReminderVesselEdit, style: .default) { _ in
            let result = basicRC.reminder(matching: identifier)
            switch result {
            case .success(let reminder):
                let vc = ReminderVesselEditViewController.newVC(basicController: self.basicRC, editVessel: reminder.vessel) { vc in
                    vc.dismiss(animated: true, completion: { deselectAnimated(true) })
                }
                self.present(vc, animated: true, completion: nil)
            case .failure(let error):
                deselectAnimated(true)
                self.present(UIAlertController(error: error, completion: nil), animated: true, completion: nil)
            }
        }
        let performReminder = UIAlertAction(title: LocalizedString.buttonTitleReminderPerform, style: .default) { _ in
            deselectAnimated(true)
            let result = basicRC.appendNewPerformToReminders(with: [identifier])
            guard case .failure(let error) = result else { return }
            self.present(UIAlertController(error: error, completion: nil), animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleCancel, style: .cancel, handler: { _ in deselectAnimated(true) })
        alert.addAction(performReminder)
        alert.addAction(editReminder)
        alert.addAction(editVessel)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

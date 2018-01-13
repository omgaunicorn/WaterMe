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

import Result
import WaterMeData
import UIKit

class ReminderMainViewController: UIViewController, HasProController, HasBasicController {
    
    class func newVC(basicRCResult: Result<BasicController, RealmError>, proController: ProController? = nil) -> UINavigationController {
        let sb = UIStoryboard(name: "ReminderMain", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderMainViewController
        vc.title = AppDelegate.LocalizedString.appTitle // set here because it works better in UITabBarController
        vc.applicationDidFinishLaunchingError = basicRCResult.error
        vc.configure(with: basicRCResult.value)
        vc.configure(with: proController)
        return navVC
    }

    private weak var collectionVC: ReminderCollectionViewController?
    private weak var dropTargetViewController: ReminderFinishDropTargetViewController?
    private var applicationDidFinishLaunchingError: RealmError?

    private lazy var plantsBBI: UIBarButtonItem = UIBarButtonItem(title: ReminderVesselMainViewController.LocalizedString.title, style: .done, target: self, action: #selector(self.plantsButtonTapped(_:)))
    private lazy var settingsBBI: UIBarButtonItem = UIBarButtonItem(title: SettingsMainViewController.LocalizedString.title, style: .plain, target: self, action: #selector(self.settingsButtonTapped(_:)))

    private let dueDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        df.doesRelativeDateFormatting = true
        return df
    }()
    
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

        // register to find out about purchases that come in at any time
        AppDelegate.shared.purchaseController?.transactionsInFlightUpdated = { [weak self] in
            self?.checkForPurchasesInFlight()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let error = self.applicationDidFinishLaunchingError {
            self.applicationDidFinishLaunchingError = nil
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
        } else if let error = self.collectionVC?.reminders?.lastError {
            self.collectionVC?.reminders?.lastError = nil
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
        } else if let migrator = AppDelegate.shared.coreDataMigrator, let basicRC = self.basicRC {
            let vc = CoreDataMigratorViewController.newVC(migrator: migrator, basicRC: basicRC) { vc, _ in
                AppDelegate.shared.coreDataMigrator = nil
                vc.dismiss(animated: true, completion: nil)
            }
            self.present(vc, animated: true, completion: nil)
        } else {
            self.checkForPurchasesInFlight()
        }
    }

    private func checkForPurchasesInFlight() {
        guard self.presentedViewController == nil else { return }
        let pc = AppDelegate.shared.purchaseController
        let transaction = pc?.nextTransactionForPresentingToUser()
        print(transaction!.transactionState)
        print(transaction)
    }

    @IBAction private func plantsButtonTapped(_ sender: Any) {
        let vc = ReminderVesselMainViewController.newVC(basicController: self.basicRC, proController: self.proRC) { vc in
            vc.dismiss(animated: true, completion: nil)
        }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction private func settingsButtonTapped(_ sender: Any) {
        let vc = SettingsMainViewController.newVC() { vc in
            vc.dismiss(animated: true) {
                // re-register to receive purchase updates
                AppDelegate.shared.purchaseController?.transactionsInFlightUpdated = {
                    self.checkForPurchasesInFlight()
                }
                self.checkForPurchasesInFlight()
            }
        }
        self.present(vc, animated: true, completion: nil)
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

    // this produces a warning and it is a really long function
    // potential for refactor, but its nice how its so contained
    func userDidSelect(reminder: Reminder,
                       from view: UIView,
                       deselectAnimated: @escaping (Bool) -> Void,
                       within viewController: ReminderCollectionViewController)
    {
        guard let basicRC = self.basicRC else { assertionFailure("Missing Realm Controller"); return; }

        // prepare information for the alert we're going to present
        let dueDateString = self.dueDateFormatter.string(from: reminder.nextPerformDate ?? Date())
        let message = reminder.localizedAlertMessage(withLocalizedDateString: dueDateString)
        let alert = UIAlertController(title: reminder.localizedAlertTitle, message: message, preferredStyle: .actionSheet)
        
        // configure popover presentation for ipad
        // popoverPresentationController is NIL on iPhones
        alert.popoverPresentationController?.sourceView = view
        let origin = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        alert.popoverPresentationController?.sourceRect = CGRect(origin: origin, size: .zero)
        alert.popoverPresentationController?.permittedArrowDirections = [.up, .down]

        // need an idenfitier starting now because this is all async
        // the reminder could be deleted or changed before the user makes a choice
        let identifier = Reminder.Identifier(reminder: reminder)
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
            switch result {
            case .failure(let error):
                self.present(UIAlertController(error: error, completion: nil), animated: true, completion: nil)
            case .success:
                let notPermVC = UIAlertController(newPermissionAlertIfNeededPresentedFrom: .right(view), selectionCompletionHandler: nil)
                guard let notificationPermissionVC = notPermVC else { return }
                self.present(notificationPermissionVC, animated: true, completion: nil)
            }
        }
        let cancel = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleCancel, style: .cancel, handler: { _ in deselectAnimated(true) })
        alert.addAction(performReminder)
        alert.addAction(editReminder)
        alert.addAction(editVessel)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

extension Reminder {
    var localizedAlertTitle: String {
        if let displayName = self.vessel?.shortLabelSafeDisplayName {
            let format = ReminderMainViewController.LocalizedString.reminderAlertTitle
            return String.localizedStringWithFormat(format, self.kind.localizedLongString, displayName)
        } else {
            return self.kind.localizedLongString
        }
    }
    func localizedAlertMessage(withLocalizedDateString dateString: String) -> String {
        if let note = self.note {
            let format = ReminderMainViewController.LocalizedString.reminderAlertMessage2Arg
            return String.localizedStringWithFormat(format, dateString, note)
        } else {
            let format = ReminderMainViewController.LocalizedString.reminderAlertMessage1Arg
            return String.localizedStringWithFormat(format, dateString)
        }
    }
}

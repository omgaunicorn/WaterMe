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
        vc.title = UIApplication.LocalizedString.appTitle // set here because it works better in UITabBarController
        vc.applicationDidFinishLaunchingError = basicRCResult.error
        vc.configure(with: basicRCResult.value)
        vc.configure(with: proController)
        return navVC
    }

    private weak var collectionVC: ReminderCollectionViewController?
    private weak var dropTargetViewController: ReminderFinishDropTargetViewController?
    private var applicationDidFinishLaunchingError: RealmError?

    private(set) lazy var plantsBBI: UIBarButtonItem = UIBarButtonItem(localizedReminderVesselButtonWithTarget: self, action: #selector(self.plantsButtonTapped(_:)))
    private(set) lazy var settingsBBI: UIBarButtonItem = UIBarButtonItem(localizedSettingsButtonWithTarget: self, action: #selector(self.settingsButtonTapped(_:)))

    var basicRC: BasicController?
    var proRC: ProController?

    let dueDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        df.doesRelativeDateFormatting = true
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure toolbar buttons
        self.navigationItem.rightBarButtonItem = self.plantsBBI
        self.navigationItem.leftBarButtonItem = self.settingsBBI

        // configure my childVC so it can tell me what the user does in the CollectionView
        self.collectionVC?.delegate = self

        // register to find out about purchases that come in at any time
        self.registerForPurchaseNotifications()
    }

    private var viewDidAppearOnce = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.log(viewOperation: .reminderList)

        guard self.viewDidAppearOnce == false else { return }
        self.viewDidAppearOnce = true
        self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
    }

    private func registerForPurchaseNotifications() {
        AppDelegate.shared.purchaseController?.transactionsInFlightUpdated = { [weak self] in
            self?.checkForPurchasesInFlight()
        }
    }

    func checkForErrorsAndOtherUnexpectedViewControllersToPresent() {
        guard self.presentedViewController == nil else { return }
        
        if let error = self.applicationDidFinishLaunchingError {
            self.applicationDidFinishLaunchingError = nil
            let alert = UIAlertController(error: error) { _ in
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
            self.present(alert, animated: true, completion: nil)
        } else if let error = self.collectionVC?.reminders?.lastError {
            self.collectionVC?.reminders?.lastError = nil
            let alert = UIAlertController(error: error) { _ in
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
            self.present(alert, animated: true, completion: nil)
        } else if let migrator = AppDelegate.shared.coreDataMigrator, let basicRC = self.basicRC {
            let vc = CoreDataMigratorViewController.newVC(migrator: migrator, basicRC: basicRC) { vc, _ in
                AppDelegate.shared.coreDataMigrator = nil
                vc.dismiss(animated: true) {
                    self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
                }
            }
            self.present(vc, animated: true, completion: nil)
        } else {
            self.checkForPurchasesInFlight()
        }
    }

    private func checkForPurchasesInFlight() {
        guard self.presentedViewController == nil else { return }

        let pc = AppDelegate.shared.purchaseController
        guard let transaction = pc?.nextTransactionForPresentingToUser() else { return }
        let _vc = PurchaseThanksViewController.newVC(for: transaction) { vc in
            guard let vc = vc else { self.checkForPurchasesInFlight(); return; }
            vc.dismiss(animated: true) {
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        }
        guard let vc = _vc else { return }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction private func plantsButtonTapped(_ sender: Any) {
        let vc = ReminderVesselMainViewController.newVC(basicController: self.basicRC, proController: self.proRC) { vc in
            vc.dismiss(animated: true) {
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction private func settingsButtonTapped(_ sender: Any) {
        let vc = SettingsMainViewController.newVC() { vc in
            vc.dismiss(animated: true) {
                // re-register to receive purchase updates
                self.registerForPurchaseNotifications()
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
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

    // Delegate from CollectionViewController
    func forceUpdateCollectionViewInsets() {
        self.updateCollectionViewInsets()
    }

    private func updateCollectionViewInsets() {
        let verticalSizeClass = self.traitCollection.verticalSizeClass
        let layoutDirection = self.traitCollection.layoutDirection
        let customInset: UIEdgeInsets
        switch verticalSizeClass {
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
            switch layoutDirection {
            case .leftToRight, .unspecified:
                customInset = UIEdgeInsets(top: 0, left: dragViewWidth, bottom: 0, right: 0)
            case .rightToLeft:
                customInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: dragViewWidth)
            }
        }
        self.collectionVC?.collectionView?.contentInset = customInset
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.settingsBBI.style_updateSettingsButtonInsets(for: self.traitCollection)
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

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

class ReminderMainViewController: StandardViewController, HasProController, HasBasicController {
    
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
        vc.userActivity = NSUserActivity(kind: .viewReminders,
                                         delegate: vc.userActivityDelegate)
        return navVC
    }

    private weak var collectionVC: ReminderCollectionViewController?
    private weak var dropTargetViewController: ReminderFinishDropTargetViewController?
    private var appUpdateAvailableVC: UIViewController?
    private var applicationDidFinishLaunchingError: RealmError?
    var userActivityToContinue: RestoredUserActivity?

    private(set) lazy var plantsBBI: UIBarButtonItem = UIBarButtonItem(localizedAddReminderVesselBBIButtonWithTarget: self,
                                                                       action: #selector(self.addPlantButtonTapped(_:)))
    private(set) lazy var settingsBBI: UIBarButtonItem = UIBarButtonItem(localizedSettingsButtonWithTarget: self,
                                                                         action: #selector(self.settingsButtonTapped(_:)))
    private var secretLongPressGestureRecognizer: UILongPressGestureRecognizer?

    var basicRC: BasicController?
    var proRC: ProController?

    let dueDateFormatter = Formatter.newDueDateFormatter
    let haptic = UINotificationFeedbackGenerator()
    //swiftlint:disable:next weak_delegate
    private let userActivityDelegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()

        // check if there are app store updates available
        self.checkForUpdates()

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
        self.configureSecretLongPressGestureRecognizer()
        self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
    }

    private func configureSecretLongPressGestureRecognizer() {
        guard
            self.secretLongPressGestureRecognizer == nil,
            let view = self.plantsBBI.value(forKey: "_view") as? UIView
        else { return }
        let gr = UILongPressGestureRecognizer(target: self,
                                              action: #selector(self.viewAllPlantsButtonTapped(_:)))
        self.secretLongPressGestureRecognizer = gr
        view.addGestureRecognizer(gr)
    }

    private func registerForPurchaseNotifications() {
        AppDelegate.shared.purchaseController?.transactionsInFlightUpdated = { [weak self] in
            self?.checkForPurchasesInFlight()
        }
    }

    private func checkForUpdates() {
        UIAlertController.newAppVersionCheckAlert({ controller in
            self.appUpdateAvailableVC = controller
            guard controller != nil, self.viewDidAppearOnce else { return }
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        }, { selection in
            switch selection {
            case .cancel:
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            case .update:
                UIApplication.shared.openAppStorePage() { _ in
                    self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
                }
            }
        })
    }

    func checkForErrorsAndOtherUnexpectedViewControllersToPresent() {
        guard self.presentedViewController == nil else {
            // user activities are allowed to continue even if the user is doing something else
            guard let activity = self.userActivityToContinue else { return }
            self.userActivityToContinue = nil
            self.continueUserActivity(activity)
            return
        }
        
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
        } else if let updateAlert = self.appUpdateAvailableVC {
            self.appUpdateAvailableVC = nil
            Analytics.log(viewOperation: .alertUpdateAvailable)
            self.present(updateAlert, animated: true, completion: nil)
        } else if let activity = self.userActivityToContinue {
            self.userActivityToContinue = nil
            self.continueUserActivity(activity)
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

    private func continueUserActivity(_ activity: RestoredUserActivity) {
        switch activity {
        case .editReminder(let identifier):
            guard
                let completion = self.collectionVC?.programmaticalySelectReminder(with: identifier),
                let basicRC = self.basicRC
            else { return }
            self.dismissAnimatedIfNeeded() {
                self.userChoseEditReminder(with: identifier,
                                           basicRC: basicRC,
                                           completion: completion)
            }
        case .editReminderVessel(let identifier):
            guard
                let basicRC = self.basicRC,
                let vessel = basicRC.reminderVessel(matching: identifier).value
            else { return }
            self.dismissAnimatedIfNeeded() {
                let vc = ReminderVesselEditViewController.newVC(basicController: basicRC,
                                                                editVessel: vessel)
                { vc in
                    vc.dismiss(animated: true, completion: nil)
                }
                self.present(vc, animated: true, completion: nil)
            }
        case .viewReminder(let identifier):
            self.dismissAnimatedIfNeeded() {
                self.collectionVC?.programaticallySimulateSelectionOfReminder(with: identifier)
            }
        case .viewReminders:
            self.dismissAnimatedIfNeeded() {
                self.collectionVC?.collectionView?.deselectAllItems(animated: true)
            }
        case .error:
            break
        }
    }

    @IBAction private func addPlantButtonTapped(_ sender: Any) {
        guard let basicRC = self.basicRC else { return }
        let editVC = ReminderVesselEditViewController.newVC(basicController: basicRC,
                                                            editVessel: nil)
        { vc in
            vc.dismiss(animated: true) {
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        }
        self.present(editVC, animated: true, completion: nil)
    }

    @IBAction private func viewAllPlantsButtonTapped(_ sender: Any) {
        guard
            let sender = sender as? UILongPressGestureRecognizer,
            case .began = sender.state
        else { return }
        let vc = ReminderVesselMainViewController.newVC(basicController: self.basicRC)
        { vc in
            vc.dismiss(animated: true, completion: nil)
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

        // BUGFIX: http://crashes.to/s/254b2d6597f
        // Sometimes the collectionview does not like having its inset changed
        // without first invalidating the layout
        // 🤞 fix as I've never seen this bug in person
        // just listening to the message from Apple
        self.collectionVC?.flow?.invalidateLayout()
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

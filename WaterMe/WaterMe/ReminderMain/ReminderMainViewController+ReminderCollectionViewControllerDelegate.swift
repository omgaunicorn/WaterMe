//
//  ReminderMainViewController+ReminderCollectionViewControllerDelegate.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 8/2/18.
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
        Analytics.log(viewOperation: .reminderVesselTap)

        // prepare information for the alert we're going to present
        let dueDateString = self.dueDateFormatter.string(from: reminder.nextPerformDate ?? Date())
        let message = reminder.localizedAlertMessage(withLocalizedDateString: dueDateString)
        let alert = UIAlertController(title: reminder.localizedAlertTitle, message: message, preferredStyle: .actionSheet)

        // configure popover presentation for ipad
        // popoverPresentationController is NIL on iPhones
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = type(of: alert).sourceRect(from: view)
        alert.popoverPresentationController?.permittedArrowDirections = [.up, .down]

        // closure that needs to be executed whenever all the alerts have disappeared
        let viewDidAppearActions = {
            deselectAnimated(true)
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        }

        // need an idenfitier starting now because this is all async
        // the reminder could be deleted or changed before the user makes a choice
        let identifier = Reminder.Identifier(reminder: reminder)
        let editReminder = UIAlertAction(title: UIApplication.LocalizedString.editReminder, style: .default) { action in
            self.userChoseEditReminder(with: identifier, in: action, basicRC: basicRC, completion: viewDidAppearActions)
        }
        let editVessel = UIAlertAction(title: UIApplication.LocalizedString.editVessel, style: .default) { action in
            self.userChoseEditVessel(withReminderIdentifier: identifier, in: action, basicRC: basicRC, completion: viewDidAppearActions)
        }
        let performReminder = UIAlertAction(title: LocalizedString.buttonTitleReminderPerform, style: .default) { action in
            self.userChosePerformReminder(with: identifier, in: action, from: view, basicRC: basicRC, completion: viewDidAppearActions)
        }
        let cancel = UIAlertAction(title: UIAlertController.LocalizedString.buttonTitleCancel, style: .cancel) { _ in
            viewDidAppearActions()
        }
        alert.addAction(performReminder)
        alert.addAction(editReminder)
        alert.addAction(editVessel)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func userChoseEditReminder(with identifier: Reminder.Identifier, in _: UIAlertAction, basicRC: BasicController, completion: (() -> Void)?) {
        let result = basicRC.reminder(matching: identifier)
        switch result {
        case .success(let reminder):
            let vc = ReminderEditViewController.newVC(basicController: self.basicRC, purpose: .existing(reminder)) { vc in
                vc.dismiss(animated: true, completion: { completion?() })
            }
            self.present(vc, animated: true, completion: nil)
        case .failure(let error):
            self.present(error: error, with: completion)
        }
    }

    private func userChoseEditVessel(withReminderIdentifier identifier: Reminder.Identifier, in _: UIAlertAction, basicRC: BasicController, completion: (() -> Void)?) {
        let result = basicRC.reminder(matching: identifier)
        switch result {
        case .success(let reminder):
            let vc = ReminderVesselEditViewController.newVC(basicController: self.basicRC, editVessel: reminder.vessel) { vc in
                vc.dismiss(animated: true, completion: { completion?() })
            }
            self.present(vc, animated: true, completion: nil)
        case .failure(let error):
            self.present(error: error, with: completion)
        }
    }

    private func userChosePerformReminder(with identifier: Reminder.Identifier, in _: UIAlertAction, from view: UIView, basicRC: BasicController, completion: (() -> Void)?) {
        let result = basicRC.appendNewPerformToReminders(with: [identifier])
        switch result {
        case .success:
            // they performed the reminder, now analytics it
            Analytics.log(event: Analytics.CRUD_Op_R.performLegacy)
            // next we need to see if they are allowing / want to give us permission to send push notifications
            let notPermVC = UIAlertController(newPermissionAlertIfNeededPresentedFrom: .right(view)) { _ in
                completion?()
            }
            // if we got a VC to present, then we need to show it
            // otherwise, just call the completion handler
            guard let notificationPermissionVC = notPermVC else {
                completion?()
                return
            }
            self.present(notificationPermissionVC, animated: true, completion: nil)
        case .failure(let error):
            self.present(error: error, with: completion)
        }
    }

    private func present(error: RealmError, with completion: (() -> Void)?) {
        let errorAlert = UIAlertController(error: error) { _ in
            completion?()
        }
        self.present(errorAlert, animated: true, completion: nil)
    }
}

//
//  ReminderMainViewController+NSUserActivity.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/11/18.
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

extension ReminderMainViewController {

    func continueUserActivityResultIfNeeded() {
        guard let result = self.userActivityResultToContinue else { return }
        self.userActivityResultToContinue = nil
        switch result {
        case .success(let activity):
            let failure: UserActivityError?
            switch activity {
            case .editReminder(let identifier):
                failure = self.continueActivityEditReminder(with: identifier)
            case .editReminderVessel(let identifier):
                failure = self.continueActivityEditReminderVessel(with: identifier)
            case .viewReminder(let identifier):
                failure = self.continueActivityViewReminder(with: identifier)
            case .viewReminders:
                failure = self.continueActivityViewAllReminders()
            case .performReminders(let ids):
                failure = self.continueActivityPerformReminders(with: ids)
            }
            guard let _failure = failure else { return }
            self.userActivityResultToContinue = .failure(_failure)
            self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
        case .failure(let error):
            self.continueActivityError(error)
        }
    }

    private func continueActivityPerformReminders(with identifiers: [Reminder.Identifier]) -> UserActivityError? {
        guard let dropVC = self.dropTargetViewController else { return .restorationFailed }
        dropVC.isDragInProgress = true
        dropVC.updateDropTargetHeightAndPlayAnimationForDragging(animated: true) { _ in
            self.userDidPerformDrop(with: identifiers, onTargetZoneWithin: nil)
            dropVC.updatePlayAnimationForDrop()
            dropVC.isDragInProgress = false
        }
        return nil
    }

    private func continueActivityEditReminder(with identifier: Reminder.Identifier) -> UserActivityError? {
        guard
            let completion = self.collectionVC?.programmaticalySelectReminder(with: identifier),
            let basicRC = self.basicRC
        else { return .reminderNotFound }
        self.dismissAnimatedIfNeeded() {
            self.userChoseEditReminder(with: identifier,
                                       basicRC: basicRC,
                                       completion: completion)
        }
        return nil
    }

    private func continueActivityEditReminderVessel(with identifier: ReminderVessel.Identifier) -> UserActivityError? {
        guard
            let basicRC = self.basicRC,
            let vessel = basicRC.reminderVessel(matching: identifier).value
        else { return .reminderVesselNotFound }
        self.dismissAnimatedIfNeeded() {
            let vc = ReminderVesselEditViewController.newVC(basicController: basicRC,
                                                            editVessel: vessel)
            { vc in
                vc.dismiss(animated: true, completion: nil)
            }
            self.present(vc, animated: true, completion: nil)
        }
        return nil
    }

    private func continueActivityViewReminder(with identifier: Reminder.Identifier) -> UserActivityError? {
        guard let indexPath = self.collectionVC?.indexPathOfReminder(with: identifier)
            else { return .reminderNotFound }
        self.dismissAnimatedIfNeeded() {
            self.collectionVC?.programaticallySimulateSelectionOfReminder(at: indexPath)
        }
        return nil
    }

    private func continueActivityViewAllReminders() -> UserActivityError? {
        self.dismissAnimatedIfNeeded() {
            self.collectionVC?.collectionView?.deselectAllItems(animated: true)
        }
        return nil
    }

    private func continueActivityError(_ error: UserActivityError) {
        self.dismissAnimatedIfNeeded() {
            UIAlertController.presentAlertVC(for: error,
                                             over: self,
                                             from: nil)
            { _ in
                self.checkForErrorsAndOtherUnexpectedViewControllersToPresent()
            }
        }
    }
}

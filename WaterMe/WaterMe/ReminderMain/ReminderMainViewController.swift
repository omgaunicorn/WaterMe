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
        vc.title = "WaterMe" // set here because it works better in UITabBarController
        vc.configure(with: basicController)
        vc.configure(with: proController)
        return navVC
    }
    
    private weak var collectionVC: ReminderCollectionViewController?
    private weak var dropTargetViewController: ReminderFinishDropTargetViewController?
    
    var basicRC: BasicController?
    var proRC: ProController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionVC?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let error = self.collectionVC?.reminders?.lastError {
            self.collectionVC?.reminders?.lastError = nil
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction private func addButtonTapped(_ sender: Any) {
        let vc = ReminderVesselMainViewController.newVC(basicController: self.basicRC, proController: self.proRC) { vc in
            vc.dismiss(animated: true, completion: nil)
        }
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction private func settingsButtonTapped(_ sender: Any) {

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionVC?.collectionView?.contentInset.top = self.dropTargetViewController?.view.bounds.height ?? 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var hasBasic = segue.destination as? HasBasicController
        hasBasic?.configure(with: self.basicRC)
        var hasPro = segue.destination as? HasProController
        hasPro?.configure(with: self.proRC)

        if let destVC = segue.destination as? ReminderCollectionViewController {
            self.collectionVC = destVC
        } else if let destVC = segue.destination as? ReminderFinishDropTargetViewController {
            self.dropTargetViewController = destVC
        }
    }
    
}

extension ReminderMainViewController: ReminderCollectionViewControllerDelegate {
    func userDidSelectReminder(with identifier: Reminder.Identifier,
                               deselectAnimated: @escaping (Bool) -> Void,
                               within viewController: ReminderCollectionViewController)
    {
        guard let basicRC = self.basicRC else { assertionFailure("Missing Realm Controller"); return; }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.delegate = viewController
        let editReminder = UIAlertAction(title: "Edit Reminder", style: .default) { _ in
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
        let editVessel = UIAlertAction(title: "Edit Plant", style: .default) { _ in
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
        let performReminder = UIAlertAction(title: "Mark Reminder as Done", style: .default) { _ in
            deselectAnimated(true)
            let result = basicRC.appendNewPerformToReminders(with: [identifier])
            guard case .failure(let error) = result else { return }
            self.present(UIAlertController(error: error, completion: nil), animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in deselectAnimated(true) })
        alert.addAction(performReminder)
        alert.addAction(editReminder)
        alert.addAction(editVessel)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}



//
//  ReminderVesselEditViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/2/17.
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
import RealmSwift
import WaterMeData
import UIKit

class ReminderVesselEditViewController: UIViewController, HasBasicController, ReminderVesselEditTableViewControllerDelegate {
    
    typealias CompletionHandler = (UIViewController) -> Void
    
    class func newVC(basicController: BasicController?,
                     editVessel vessel: ReminderVessel? = nil,
                     completionHandler: @escaping CompletionHandler) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderVesselEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderVesselEditViewController
        vc.configure(with: basicController)
        vc.completionHandler = completionHandler
        if let vessel = vessel {
            vc.vesselResult = .success(vessel)
        } else {
            vc.vesselResult = basicController?.newReminderVessel()
        }
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderVesselEditTableViewController?
    @IBOutlet private weak var deleteButton: UIBarButtonItem?
    
    var basicRC: BasicController?
    private(set) var vesselResult: Result<ReminderVessel, RealmError>!
    private var completionHandler: CompletionHandler!
    
    private func vesselChanged(_ changes: ObjectChange) {
        switch changes {
        case .change:
            self.tableViewController?.reloadPhotoAndName()
        case .deleted, .error:
            self.notificationToken?.invalidate()
            self.notificationToken = nil
            self.completionHandler?(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startNotifications()
        
        self.deleteButton?.title = UIAlertController.LocalizedString.buttonTitleDelete
        self.title = UIAlertController.LocalizedString.buttonTitleNewPlant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if case .failure(let error) = self.vesselResult! {
            self.vesselResult = nil
            let alert = UIAlertController(error: error) { _ in
                self.completionHandler?(self)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? ReminderVesselEditTableViewController else { return }
        self.tableViewController = destVC
        self.tableViewController?.delegate = self
    }
    
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        guard let vessel = self.vesselResult.value, let basicRC = self.basicRC
            else { assertionFailure("Missing ReminderVessel or Realm Controller"); return; }
        let deleteResult = basicRC.delete(vessel: vessel)
        switch deleteResult {
        case .success:
            self.tableViewController?.reminderVesselWasDeleted()
            self.completionHandler?(self)
        case .failure(let error):
            let alert = UIAlertController(error: error) { _ in
                self.completionHandler?(self)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard let vessel = self.vesselResult.value else { assertionFailure("Missing ReminderVessel"); return; }
        
        let sender = sender as? UIBarButtonItem
        assert(sender != nil, "Expected UIBarButtonItem to call this method")
        let errors = vessel.isUIComplete
        switch errors.isEmpty {
        case true:
            self.completionHandler?(self)
        case false:
            UIAlertController.presentAlertVC(for: errors, over: self, from: sender) { [unowned self] selection in
                switch selection {
                case .cancel:
                    break
                case .saveAnyway:
                    self.completionHandler?(self)
                case .error(let error):
                    switch error {
                    case .missingIcon:
                        self.userChosePhotoChange(controller: self.tableViewController)
                    case .missingName:
                        self.tableViewController?.nameTextFieldBecomeFirstResponder()
                    case .noReminders:
                        self.userChoseAddReminder(controller: self.tableViewController)
                    }
                }
            }
        }
    }
    
    private func updateIcon(_ icon: ReminderVessel.Icon) {
        guard let vessel = self.vesselResult.value, let basicRC = self.basicRC
            else { assertionFailure("Missing ReminderVessel or Realm Controller"); return; }
        let updateResult = basicRC.update(icon: icon, in: vessel)
        guard case .failure(let error) = updateResult else { return }
        let alert = UIAlertController(error: error, completion: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    func userChosePhotoChange(controller: ReminderVesselEditTableViewController?) {
        let vc = UIAlertController.emojiPhotoActionSheet() { choice in
            switch choice {
            case .camera:
                let vc = SelfContainedImagePickerController.newCameraVC() { image, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let image = image else { return }
                    self.updateIcon(ReminderVessel.Icon(rawImage: image))
                }
                self.present(vc, animated: true, completion: nil)
            case .photos:
                let vc = SelfContainedImagePickerController.newPhotosVC() { image, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let image = image else { return }
                    self.updateIcon(ReminderVessel.Icon(rawImage: image))
                }
                self.present(vc, animated: true, completion: nil)
            case .emoji:
                let vc = EmojiPickerViewController.newVC() { emoji, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let emoji = emoji else { return }
                    self.updateIcon(.emoji(emoji))
                }
                self.present(vc, animated: true, completion: nil)
            case .error(let errorVC):
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func userChangedName(to newName: String, andDismissKeyboard dismissKeyboard: Bool, controller: ReminderVesselEditTableViewController?) {
        guard let vessel = self.vesselResult.value, let basicRC = self.basicRC
            else { assertionFailure("Missing ReminderVessel or Realm Controller"); return; }
      self.notificationToken?.invalidate() // stop the update notifications from causing the tableview to reload
        let updateResult = basicRC.update(displayName: newName, in: vessel)
        if case .failure(let error) = updateResult {
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
        self.startNotifications()
        guard dismissKeyboard else { return }
        self.tableViewController?.reloadPhotoAndName()
    }
    
    func userChoseAddReminder(controller: ReminderVesselEditTableViewController?) {
        guard let vessel = self.vesselResult.value else { assertionFailure("Missing ReminderVessel"); return; }
        let addReminderVC = ReminderEditViewController.newVC(basicController: basicRC, purpose: .new(vessel)) { vc in
            vc.dismiss(animated: true, completion: nil)
        }
        self.present(addReminderVC, animated: true, completion: nil)
    }
    
    func userChose(reminder: Reminder, controller: ReminderVesselEditTableViewController?) {
        let editReminderVC = ReminderEditViewController.newVC(basicController: basicRC, purpose: .existing(reminder)) { [weak self] vc in
            vc.dismiss(animated: true, completion: { self?.tableViewController?.tableView.deselectSelectedRows(animated: true) })
        }
        self.present(editReminderVC, animated: true, completion: nil)
    }
    
    func userDeleted(reminder: Reminder, controller: ReminderVesselEditTableViewController?) -> Bool {
        guard let basicRC = self.basicRC else { assertionFailure("Missing Realm Controller."); return false; }
        let deleteResult = basicRC.delete(reminder: reminder)
        switch deleteResult {
        case .success:
            return true
        case .failure(let error):
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    private func startNotifications() {
      self.notificationToken = self.vesselResult.value?.observe({ [weak self] in self?.vesselChanged($0) })
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
      self.notificationToken?.invalidate()
    }
}

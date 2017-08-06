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

import RealmSwift
import WaterMeData
import UIKit

class ReminderVesselEditViewController: UIViewController, HasBasicController, ReminderVesselEditTableViewControllerDelegate {
    
    typealias CompletionHandler = (UIViewController) -> Void
    
    class func newVC(basicRC: BasicController,
                     editVessel vessel: ReminderVessel? = nil,
                     completionHandler: @escaping CompletionHandler) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderVesselEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderVesselEditViewController
        vc.configure(with: basicRC)
        vc.completionHandler = completionHandler
        let vessel = vessel ?? basicRC.newReminderVessel()
        vc.vessel = vessel
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderVesselEditTableViewController?
    @IBOutlet private weak var deleteButton: UIBarButtonItem?
    
    var basicRC: BasicController?
    var vessel: ReminderVessel!
    private var completionHandler: CompletionHandler!
    
    private func vesselChanged(_ changes: ObjectChange) {
        switch changes {
        case .change:
            self.tableViewController?.reloadPhotoAndName()
        case .deleted, .error:
            self.completionHandler?(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startNotifications()
        
        self.deleteButton?.title = "Delete"
        self.title = "New Plant"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? ReminderVesselEditTableViewController else { return }
        self.tableViewController = destVC
        self.tableViewController?.delegate = self
    }
    
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        self.basicRC?.delete(vessel: self.vessel)
        self.completionHandler?(self)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        let sender = sender as? UIBarButtonItem
        assert(sender != nil, "Expected UIBarButtonItem to call this method")
        let errors = self.vessel.isUIComplete
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
        self.basicRC?.update(icon: icon, in: self.vessel)
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
        self.notificationToken?.stop() // stop the update notifications from causing the tableview to reload
        self.basicRC?.update(displayName: newName, in: self.vessel)
        self.startNotifications()
        guard dismissKeyboard else { return }
        self.tableViewController?.reloadPhotoAndName()
    }
    
    func userChoseAddReminder(controller: ReminderVesselEditTableViewController?) {
        guard let basicRC = self.basicRC else { return }
        let addReminderVC = ReminderEditViewController.newVC(basicRC: basicRC, purpose: .new(self.vessel)) { vc in
            vc.dismiss(animated: true, completion: nil)
        }
        self.present(addReminderVC, animated: true, completion: nil)
    }
    
    func userChose(reminder: Reminder, controller: ReminderVesselEditTableViewController?) {
        guard let basicRC = self.basicRC else { return }
        let editReminderVC = ReminderEditViewController.newVC(basicRC: basicRC, purpose: .existing(reminder)) { [weak self] vc in
            vc.dismiss(animated: true, completion: { self?.tableViewController?.tableView.deselectSelectedRows(animated: true) })
        }
        self.present(editReminderVC, animated: true, completion: nil)
    }
    
    func userDeleted(reminder: Reminder, controller: ReminderVesselEditTableViewController?) -> Bool {
        self.basicRC?.delete(reminder: reminder)
        return true
    }
    
    private func startNotifications() {
        self.notificationToken = self.vessel.addNotificationBlock({ [weak self] in self?.vesselChanged($0) })
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

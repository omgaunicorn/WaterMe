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
import SimpleImageViewer
import IntentsUI
import UIKit

class ReminderVesselEditViewController: StandardViewController, HasBasicController, ReminderVesselEditTableViewControllerDelegate {
    
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
        vc.title = UIApplication.LocalizedString.editVessel
        vc.configure(with: basicController)
        vc.completionHandler = completionHandler
        if let vessel = vessel {
            vc.vesselResult = .success(vessel)
        } else {
            Analytics.log(event: Analytics.CRUD_Op_RV.create)
            vc.vesselResult = basicController?.newReminderVessel()
        }
        vc.userActivity = NSUserActivity(kind: .editReminderVessel,
                                         delegate: vc.userActivityDelegate)
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderVesselEditTableViewController?

    private lazy var deleteBBI: UIBarButtonItem = UIBarButtonItem(localizedDeleteButtonWithTarget: self, action: #selector(self.deleteButtonTapped(_:)))
    private lazy var doneBBI: UIBarButtonItem = UIBarButtonItem(localizedDoneButtonWithTarget: self, action: #selector(self.doneButtonTapped(_:)))
    
    var basicRC: BasicController?
    private(set) var vesselResult: Result<ReminderVessel, RealmError>?
    private var completionHandler: CompletionHandler!
    //swiftlint:disable:next weak_delegate
    private let userActivityDelegate: UserActivityConfiguratorProtocol = UserActivityConfigurator()

    private func vesselChanged(_ changes: ObjectChange) {
        switch changes {
        case .change(let properties):
            /*
             BUGFIX: http://crashes.to/s/5a4715f46b9
             I think this fixes this bug crash. Its caused because this change notification was telling the icon and name section to reload
             But at the same time, the reminders section was getting its normal updates.
             This could cause both to happen simultaneously and the sanity check of the section reload would fail because
             the reminders section also changed at the same time

             This fixes the problem by checking which properties changed and only reloads the icon/name section if the reminder section did not change
            */
            let changedDisplayName = ReminderVessel.propertyChangesContainDisplayName(properties)
            let changedIconEmoji = ReminderVessel.propertyChangesContainIconEmoji(properties)
            let changedReminders = ReminderVessel.propertyChangesContainReminders(properties)
            let changedPointlessBloop = ReminderVessel.propertyChangesContainPointlessBloop(properties)

            switch (changedDisplayName, changedIconEmoji, changedReminders, changedPointlessBloop) {
            case (true, _, false, _),
                 (_, true, false, _):
                // changed icon or name but NOT reminders
                self.tableViewController?.reloadPhotoAndName()
            case (false, false, true, _),
                // changed reminders but NOT displayName or Icon
                // do nothing if reminders change because they handle themselves
                (false, false, false, true):
                // pointless bloop changed. This is a hack I use to make sure subobjects / parent objects are changed when their
                // parents/children are changed. That way things refresh when needed
                // so that collections are appropriately refreshed
                // do nothing because only a parent or child changed and we don't show any of them
                // except children reminders and they update their own display
                break
            default:
                // error notification when unhandled changes happen. I want to know about these in analytics
                // so I can troubleshoot this further if needed.
                // if nothing happens here, I can remove this and the pointless bloop test.
                let error = NSError(reminderVesselPropertyChangeUnknownCaseErrorWithChangedKeyPaths: properties.map({ $0.name }))
                assertionFailure(String(describing: error))
                Analytics.log(error: error)
                log.warning(error)
                self.tableViewController?.tableView?.reloadData()
            }
        case .error(let error):
            Analytics.log(error: error)
            log.error(error)
            fallthrough
        case .deleted:
            self.reminderVesselWasDeleted()
        }
        // All changes should dirty the User Activity
        self.userDirtiedUserActivity()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.deleteBBI
        self.navigationItem.rightBarButtonItem = self.doneBBI

        self.startNotifications()
        self.userActivityDelegate.currentReminderVessel = { [weak self] in
            // should be unowned because this object should not exist longer
            // than the view controller. But since NIL is a possible return value
            // it just seems safer to go with weak
            return self?.vesselResult?.value
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.log(viewOperation: .editReminderVessel)
        
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
        self.view.endEditing(false)
        guard
            let vessel = self.vesselResult?.value,
            let basicRC = self.basicRC,
            let sender = sender as? UIBarButtonItem
        else {
            assertionFailure("Missing ReminderVessel or Realm Controller")
            self.completionHandler?(self)
            return
        }
        let confirmation = UIAlertController(localizedDeleteConfirmationAlertPresentedFrom: .left(sender)) { confirmed in
            guard confirmed == true else { return }

            Analytics.log(event: Analytics.CRUD_Op_RV.delete)

            let deleteResult = basicRC.delete(vessel: vessel)
            switch deleteResult {
            case .success:
                self.reminderVesselWasDeleted()
            case .failure(let error):
                let alert = UIAlertController(error: error) { _ in
                    self.completionHandler?(self)
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.present(confirmation, animated: true, completion: nil)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        self.view.endEditing(false)
        guard let vessel = self.vesselResult?.value else { assertionFailure("Missing ReminderVessel"); return; }

        Analytics.log(event: Analytics.CRUD_Op_RV.update)
        
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
        guard let vessel = self.vesselResult?.value, let basicRC = self.basicRC else {
            assertionFailure("Missing ReminderVessel or Realm Controller")
            return
        }
        let updateResult = basicRC.update(icon: icon, in: vessel)
        guard case .failure(let error) = updateResult else { return }
        let alert = UIAlertController(error: error, completion: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    func userChosePhotoChange(controller: ReminderVesselEditTableViewController?) {
        self.view.endEditing(false)
        let imageAlreadyChosen = self.vesselResult?.value?.icon?.image != nil
        let vc = UIAlertController.emojiPhotoActionSheet(withAlreadyChosenImage: imageAlreadyChosen)
        { choice in
            switch choice {
            case .camera:
                let vc = ImagePickerCropperViewController.newCameraVC() { image, vc in
                    vc.dismiss(animated: true, completion: nil)
                    guard let image = image else { return }
                    self.updateIcon(ReminderVessel.Icon(rawImage: image))
                }
                self.present(vc, animated: true, completion: nil)
            case .photos:
                let vc = ImagePickerCropperViewController.newPhotosVC() { image, vc in
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
            case .viewCurrentPhoto:
                guard let image = self.vesselResult?.value?.icon?.image else { return }
                let config = DismissHandlingImageViewerConfiguration(image: image) { vc in
                    vc.dismiss(animated: true, completion: nil)
                }
                let vc = DismissHandlingImageViewerController(configuration: config)
                self.present(vc, animated: true, completion: nil)
            case .error(let errorVC):
                self.present(errorVC, animated: true, completion: nil)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func userChangedName(to newName: String, controller: ReminderVesselEditTableViewController?) {
        guard let vessel = self.vesselResult?.value, let basicRC = self.basicRC else {
            assertionFailure("Missing ReminderVessel or Realm Controller")
            return
        }
        self.notificationToken?.invalidate() // stop the update notifications from causing the tableview to reload
        let updateResult = basicRC.update(displayName: newName, in: vessel)
        if case .failure(let error) = updateResult {
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
        self.startNotifications()
        // Item changed outside of the change block, time to dirty
        self.userDirtiedUserActivity()
    }
    
    func userChoseAddReminder(controller: ReminderVesselEditTableViewController?) {
        self.view.endEditing(false)
        guard let vessel = self.vesselResult?.value else {
            assertionFailure("Missing ReminderVessel")
            return
        }
        let addReminderVC = ReminderEditViewController.newVC(basicController: basicRC, purpose: .new(vessel)) { vc in
            vc.dismiss(animated: true, completion: nil)
        }
        self.present(addReminderVC, animated: true, completion: nil)
    }
    
    func userChose(reminder: Reminder,
                   deselectRowAnimated: ((Bool) -> Void)?,
                   controller: ReminderVesselEditTableViewController?)
    {
        self.view.endEditing(false)
        let editReminderVC = ReminderEditViewController.newVC(basicController: basicRC,
                                                              purpose: .existing(reminder))
        { vc in
            vc.dismiss(animated: true, completion: { deselectRowAnimated?(true) })
        }
        self.present(editReminderVC, animated: true, completion: nil)
    }

    func userChose(siriShortcut: ReminderVesselEditTableViewController.SiriShortcut,
                   deselectRowAnimated: ((Bool) -> Void)?,
                   controller: ReminderVesselEditTableViewController?)
    {
        guard #available(iOS 12.0, *) else {
            let vc = UIAlertController(localizedSiriShortcutsUnavailableAlertWithCompletionHandler: {
                deselectRowAnimated?(true)
            })
            self.present(vc, animated: true, completion: nil)
            return
        }
        guard
            let activity = self.userActivity,
            activity.activityType == NSUserActivity.Kind.editReminderVessel.rawValue
        else {
            assertionFailure("Unexpected User Activity")
            return
        }
        let shortcut = INShortcut(userActivity: activity)
        let vc = ClosureDelegatingAddVoiceShortcutViewController(shortcut: shortcut)
        vc.completion = { vc, result in
            vc.dismiss(animated: true) {
                deselectRowAnimated?(true)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func userDeleted(reminder: Reminder, controller: ReminderVesselEditTableViewController?) -> Bool {
        self.view.endEditing(false)
        guard let basicRC = self.basicRC else {
            assertionFailure("Missing Realm Controller.")
            return false
        }
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

    private func userDirtiedUserActivity() {
        self.userActivity?.needsSave = true
    }

    private func reminderVesselWasDeleted() {
        self.vesselResult = nil
        self.notificationToken?.invalidate()
        self.notificationToken = nil
        self.tableViewController?.reloadAll()
        self.completionHandler?(self)
    }
    
    private func startNotifications() {
        self.notificationToken =
            self.vesselResult?.value?.observe({ [weak self] in self?.vesselChanged($0) })
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.invalidate()
    }
}

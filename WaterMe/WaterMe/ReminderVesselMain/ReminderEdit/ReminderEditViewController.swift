//
//  ReminderEditViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 6/22/17.
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
import RealmSwift
import UIKit

class ReminderEditViewController: UIViewController, HasBasicController {
    
    enum Purpose {
        case new(ReminderVessel), existing(Reminder)
    }
    typealias CompletionHandler = (UIViewController) -> Void
    
    class func newVC(basicController: BasicController?,
                     purpose: Purpose,
                     completionHandler: @escaping CompletionHandler) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderEditViewController
        vc.title = UIApplication.LocalizedString.editReminder
        vc.configure(with: basicController)
        vc.completionHandler = completionHandler
        switch purpose {
        case .new(let vessel):
            Analytics.log(event: Analytics.CRUD_Op_R.create)
            vc.reminderResult = basicController?.newReminder(for: vessel)
        case .existing(let reminder):
            vc.reminderResult = .success(reminder)
        }
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderEditTableViewController?

    private lazy var deleteBBI: UIBarButtonItem = UIBarButtonItem(localizedDeleteButtonWithTarget: self, action: #selector(self.deleteButtonTapped(_:)))
    private lazy var doneBBI: UIBarButtonItem = UIBarButtonItem(localizedSaveButtonWithTarget: self, action: #selector(self.doneButtonTapped(_:)))

    var basicRC: BasicController?
    private var reminderResult: Result<Reminder, RealmError>?
    private var completionHandler: CompletionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.deleteBBI
        self.navigationItem.rightBarButtonItem = self.doneBBI
        
        self.tableViewController?.reminder = { [unowned self] in return self.reminderResult }
        self.tableViewController?.kindChanged = { [unowned self] in self.update(kind: $0, fromKeyboard: $1) }
        self.tableViewController?.noteChanged = { [unowned self] in self.update(note: $0, fromKeyboard: true) }
        self.tableViewController?.intervalChosen = { [unowned self] in self.intervalChosen($0) }
        self.startNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Analytics.log(viewOperation: .editReminder)
        
        if case .failure(let error) = self.reminderResult! {
            self.reminderResult = nil
            let alert = UIAlertController(error: error) { _ in
                self.completionHandler?(self)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func reminderChanged(_ changes: ObjectChange) {
        switch changes {
        case .change:
            self.tableViewController?.tableView.reloadData()
        case .error(let error):
            Analytics.log(error: error)
            log.error(error)
            fallthrough
        case .deleted:
            self.reminderResult = nil
            self.notificationToken?.invalidate()
            self.notificationToken = nil
            self.completionHandler?(self)
        }
    }
    
    private func update(kind: Reminder.Kind? = nil, interval: Int? = nil, note: String? = nil, fromKeyboard: Bool = false) {
        // make sure we have the info we needed
        guard let reminder = self.reminderResult?.value, let basicRC = self.basicRC
            else { assertionFailure("Missing Reminder or Realm Controller"); return; }
        
        // if this came from the keyboard stop notifications
        // so the keyboard doesn't get dismissed because of tableview reloads
        if fromKeyboard == true {
          self.notificationToken?.invalidate()
        }
        
        // after we exit this scope, we need to turn notifications back on
        // again, only if the from keyboard variable is true
        defer {
            if fromKeyboard == true {
                self.startNotifications()
            }
        }
        
        // update the Reminder in Realm
        let updateResult = basicRC.update(kind: kind, interval: interval, note: note, in: reminder)
        
        // show the user errors that may have ocurred
        guard case .failure(let error) = updateResult else { return }
        let alert = UIAlertController(error: error, completion: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func intervalChosen(_ deselectSelectedCell: @escaping () -> Void) {
        self.view.endEditing(false)
        guard let existingValue = self.reminderResult?.value?.interval
            else { assertionFailure("No Reminder Present"); self.completionHandler?(self); return; }
        let vc = ReminderIntervalPickerViewController.newVC(from: self.storyboard, existingValue: existingValue) { vc, newValue in
            vc.dismiss(animated: true) {
                deselectSelectedCell()
                guard let newValue = newValue else { return }
                self.update(interval: newValue)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        self.view.endEditing(false)
        guard
            let reminder = self.reminderResult?.value,
            let basicRC = self.basicRC,
            let sender = sender as? UIBarButtonItem
        else {
            assertionFailure("Missing Reminder or Realm Controller.")
            self.completionHandler?(self)
            return
        }

        let confirmation = UIAlertController(localizedDeleteConfirmationAlertPresentedFrom: .left(sender)) { confirmed in

            Analytics.log(event: Analytics.CRUD_Op_R.delete)

            guard confirmed == true else { return }
            let deleteResult = basicRC.delete(reminder: reminder)
            switch deleteResult {
            case .success:
                self.completionHandler?(self)
            case .failure(let error):
                let alert = UIAlertController(error: error, completion: nil)
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.present(confirmation, animated: true, completion: nil)
    }
    
    @IBAction private func doneButtonTapped(_ _sender: Any) {

        Analytics.log(event: Analytics.CRUD_Op_R.update)

        self.view.endEditing(false)
        guard let sender = _sender as? UIBarButtonItem, let reminder = self.reminderResult?.value else {
            let message = "Expected UIBarButtonItem to call this method"
            log.error(message)
            assertionFailure(message)
            self.completionHandler?(self)
            return
        }
        let errors = reminder.isUIComplete
        switch errors.isEmpty {
        case true:
            self.completionHandler?(self)
        case false:
            UIAlertController.presentAlertVC(for: errors, over: self, from: sender) { selection in
                switch selection {
                case .cancel:
                    break
                case .error:
                    self.tableViewController?.nameTextFieldBecomeFirstResponder()
                case .saveAnyway:
                    self.completionHandler?(self)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableVC = segue.destination as? ReminderEditTableViewController {
            self.tableViewController = tableVC
        }
    }
    
    private func startNotifications() {
      self.notificationToken = self.reminderResult?.value?.observe({ [weak self] in self?.reminderChanged($0) })
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
      self.notificationToken?.invalidate()
    }
}

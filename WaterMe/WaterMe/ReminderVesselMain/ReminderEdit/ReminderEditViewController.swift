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
    
    class func newVC(basicRC: BasicController,
                     purpose: Purpose,
                     completionHandler: @escaping CompletionHandler) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderEditViewController
        vc.configure(with: basicRC)
        vc.completionHandler = completionHandler
        switch purpose {
        case .new(let vessel):
            vc.reminder = basicRC.newReminder(for: vessel)
        case .existing(let reminder):
            vc.reminder = .success(reminder)
        }
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderEditTableViewController?
    @IBOutlet private weak var deleteButton: UIBarButtonItem?
    
    var basicRC: BasicController?
    private var reminder: Result<Reminder, RealmError>?
    private var completionHandler: CompletionHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.deleteButton?.title = "Delete"
        
        self.tableViewController = self.childViewControllers.first()
        self.tableViewController?.reminder = { [unowned self] in return self.reminder }
        self.tableViewController?.kindChanged = { [unowned self] in self.update(kind: $0, fromKeyboard: $1) }
        self.tableViewController?.noteChanged = { [unowned self] in self.update(note: $0, fromKeyboard: true) }
        self.tableViewController?.intervalChosen = { [unowned self] in self.intervalChosen() }
        self.startNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let result = self.reminder, case .failure(let error) = result {
            self.reminder = nil
            let alert = UIAlertController(error: error) { selection in
                self.completionHandler?(self)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func reminderChanged(_ changes: ObjectChange) {
        switch changes {
        case .change:
            self.tableViewController?.tableView.reloadData()
        case .deleted, .error:
            self.completionHandler?(self)
        }
    }
    
    private func update(kind: Reminder.Kind? = nil, interval: Int? = nil, note: String? = nil, fromKeyboard: Bool = false) {
        // make sure we have the info we needed
        guard let reminder = self.reminder?.value, let basicRC = self.basicRC
            else { assertionFailure("Missing Reminder or Realm Controller"); return; }
        
        // if this came from the keyboard stop notifications
        // so the keyboard doesn't get dismissed because of tableview reloads
        if fromKeyboard == true {
            self.notificationToken?.stop()
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
    
    private func intervalChosen() {
        let existingValue = self.reminder!.value!.interval
        let vc = ReminderIntervalPickerViewController.newVC(from: self.storyboard, existingValue: existingValue) { vc, newValue in
            vc.dismiss(animated: true, completion: nil)
            guard let newValue = newValue else { return }
            self.update(interval: newValue)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        guard let reminder = self.reminder?.value, let basicRC = self.basicRC
            else { assertionFailure("Missing Reminder or Realm Controller."); self.completionHandler?(self); return; }
        let deleteResult = basicRC.delete(reminder: reminder)
        switch deleteResult {
        case .success:
            self.completionHandler?(self)
        case .failure(let error):
            let alert = UIAlertController(error: error) { selection in
                self.completionHandler?(self)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        guard let reminder = self.reminder?.value else { self.completionHandler?(self); return; }
        let sender = sender as? UIBarButtonItem
        assert(sender != nil, "Expected UIBarButtonItem to call this method")
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
    
    private func startNotifications() {
        self.notificationToken = self.reminder?.value?.addNotificationBlock({ [weak self] in self?.reminderChanged($0) })
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

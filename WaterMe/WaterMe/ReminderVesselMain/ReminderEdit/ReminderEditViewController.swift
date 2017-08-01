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
            vc.reminder = reminder
        }
        return navVC
    }
    
    /*@IBOutlet*/ private weak var tableViewController: ReminderEditTableViewController?
    @IBOutlet private weak var deleteButton: UIBarButtonItem?
    
    var basicRC: BasicController?
    private var reminder: Reminder!
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
    
    private func reminderChanged(_ changes: ObjectChange) {
        switch changes {
        case .change:
            self.tableViewController?.tableView.reloadData()
        case .deleted, .error:
            self.completionHandler?(self)
        }
    }
    
    private func update(kind: Reminder.Kind? = nil, interval: Int? = nil, note: String? = nil, fromKeyboard: Bool = false) {
        if fromKeyboard == true {
            self.notificationToken?.stop()
        }
        self.basicRC?.update(kind: kind, interval: interval, note: note, in: self.reminder)
        if fromKeyboard == true {
            self.startNotifications()
        }
    }
    
    private func intervalChosen() {
        let existingValue = self.reminder.interval
        let vc = ReminderIntervalPickerViewController.newVC(from: self.storyboard, existingValue: existingValue) { vc, newValue in
            vc.dismiss(animated: true, completion: nil)
            guard let newValue = newValue else { return }
            self.update(interval: newValue)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction private func deleteButtonTapped(_ sender: Any) {
        // delete the object
        self.basicRC?.delete(reminder: self.reminder)
        self.completionHandler?(self)
    }
    
    @IBAction private func doneButtonTapped(_ sender: Any) {
        let result = self.reminder.isUIComplete
        switch result {
        case .success:
            self.completionHandler?(self)
        case .failure(let error):
            log.error(error)
            let alertVC = UIAlertController(error: error, completion: nil)
            alertVC.addSaveAnywayAction(with: { [unowned self] _ in self.completionHandler?(self) })
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    private func startNotifications() {
        self.notificationToken = self.reminder.addNotificationBlock({ [weak self] in self?.reminderChanged($0) })
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
    
}

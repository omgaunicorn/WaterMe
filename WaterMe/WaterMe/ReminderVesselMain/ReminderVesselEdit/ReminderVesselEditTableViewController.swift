//
//  ReminderVesselEditTableViewController.swift
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
import WaterMeData
import RealmSwift
import UIKit

protocol ReminderVesselEditTableViewControllerDelegate: class {
    var vesselResult: Result<ReminderVessel, RealmError>! { get }
    func userChosePhotoChange(controller: ReminderVesselEditTableViewController?)
    func userChangedName(to: String, andDismissKeyboard: Bool, controller: ReminderVesselEditTableViewController?)
    func userChoseAddReminder(controller: ReminderVesselEditTableViewController?)
    func userChose(reminder: Reminder, controller: ReminderVesselEditTableViewController?)
    func userDeleted(reminder: Reminder, controller: ReminderVesselEditTableViewController?) -> Bool
}

class ReminderVesselEditTableViewController: UITableViewController {
    
    private enum Section: Int {
        case photo = 0, name, reminders
        static let count = 3
        var localizedTitle: String {
            switch self {
            case .photo:
                return ReminderVessel.LocalizedString.photo
            case .name:
                return ReminderVessel.LocalizedString.name
            case .reminders:
                return ReminderVessel.LocalizedString.reminders
            }
        }
    }
    
    weak var delegate: ReminderVesselEditTableViewControllerDelegate?
    
    func reloadPhotoAndName() {
        self.tableView.reloadSections(IndexSet([Section.photo.rawValue, Section.name.rawValue]), with: .automatic)
    }
    
    func reloadAll() {
        self.notificationToken?.invalidate()
        self.remindersData = nil
        self.tableView.reloadData()
        self.notificationToken = self.delegate?.vesselResult.value?.reminders.observe({ [weak self] in self?.remindersChanged($0) })
    }
    
    func reloadReminders() {
        self.notificationToken?.invalidate()
        self.remindersData = nil
        self.tableView.reloadSections(IndexSet([Section.reminders.rawValue]), with: .automatic)
        self.notificationToken = self.delegate?.vesselResult.value?.reminders.observe({ [weak self] in self?.remindersChanged($0) })
    }
    
    func nameTextFieldBecomeFirstResponder() {
        let indexPath = IndexPath(row: 0, section: Section.name.rawValue)
        UIView.animate(withDuration: UIApplication.style_animationDurationNormal, animations: {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }, completion: { _ in
            let cell = self.tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell
            cell?.textFieldBecomeFirstResponder()
        })
    }

    func reminderVesselWasDeleted() {
        self.notificationToken?.invalidate()
        self.notificationToken = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(ReminderTableViewCell.nib, forCellReuseIdentifier: ReminderTableViewCell.reuseID)
        self.tableView.register(TextFieldTableViewCell.nib, forCellReuseIdentifier: TextFieldTableViewCell.reuseID)
        self.tableView.register(OptionalAddButtonTableViewHeaderFooterView.nib, forHeaderFooterViewReuseIdentifier: OptionalAddButtonTableViewHeaderFooterView.reuseID)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 40
        self.reloadAll()
    }
    
    private var remindersData: List<Reminder>?
    
    private func remindersChanged(_ changes: RealmCollectionChange<List<Reminder>>) {
        switch changes {
        case .initial(let data):
            self.remindersData = data
            self.tableView.reloadSections(IndexSet([Section.reminders.rawValue]), with: .automatic)
        case .update(_, let deletions, let insertions, let modifications):
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: Section.reminders.rawValue) }), with: .automatic)
            self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: Section.reminders.rawValue)}), with: .automatic)
            self.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: Section.reminders.rawValue) }), with: .automatic)
            self.tableView.endUpdates()
        case .error:
            self.remindersData = nil
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { assertionFailure("Unknown Section"); return 0; }
        switch section {
        case .name:
            return 1
        case .photo:
            return 1
        case .reminders:
            return self.remindersData?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { assertionFailure("Unknown Section"); return UITableViewCell(); }
        switch section {
        case .name:
            let id = TextFieldTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? TextFieldTableViewCell
            cell?.setTextField(text: self.delegate?.vesselResult.value?.displayName)
            cell?.setLabelText(nil, andTextFieldPlaceHolderText: "Plant Name")
            cell?.textChanged = { [unowned self] newName in
                self.delegate?.userChangedName(to: newName, andDismissKeyboard: false, controller: self)
            }
            return _cell
        case .photo:
            let id = ReminderVesselIconTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderVesselIconTableViewCell
            cell?.configure(with: self.delegate?.vesselResult.value?.icon)
            cell?.iconButtonTapped = { [unowned self] in self.delegate?.userChosePhotoChange(controller: self) }
            return _cell
        case .reminders:
            let id = ReminderTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderTableViewCell
            cell?.configure(with: self.remindersData?[indexPath.row])
            return _cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { assertionFailure("Unknown Section"); return; }
        switch section {
        case .name, .photo:
        break // ignore
        case .reminders:
            guard let reminder = self.remindersData?[indexPath.row] else { return }
            self.delegate?.userChose(reminder: reminder, controller: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure("Unknown Section")
            return UISwipeActionsConfiguration(actions: [])
        }
        switch section {
        case .name, .photo:
            return UISwipeActionsConfiguration(actions: [])
        case .reminders:
            let deleteAction = UIContextualAction(style: .destructive, title: UIAlertController.LocalizedString.buttonTitleDelete) { [unowned self] _, _, successfullyDeleted in
                guard let reminder = self.remindersData?[indexPath.row] else {
                    successfullyDeleted(false)
                    return
                }
                let deleted = self.delegate?.userDeleted(reminder: reminder, controller: self) ?? false
                successfullyDeleted(deleted)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Section(rawValue: section) else { assertionFailure("Unknown Section"); return nil; }
        let id = OptionalAddButtonTableViewHeaderFooterView.reuseID
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as? OptionalAddButtonTableViewHeaderFooterView
        switch section {
        case .name, .photo:
            view?.isAddButtonHidden = true
            view?.addButtonTapped = nil
        case .reminders:
            view?.isAddButtonHidden = false
            view?.addButtonTapped = { [unowned self] in self.delegate?.userChoseAddReminder(controller: self) }
        }
        return view
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { assertionFailure("Unknown Section"); return nil; }
        return section.localizedTitle
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.invalidate()
    }
}

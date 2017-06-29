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

import WaterMeData
import UIKit

protocol ReminderVesselEditTableViewControllerDelegate: class {
    var vessel: ReminderVessel! { get }
    func userChosePhotoChange(controller: ReminderVesselEditTableViewController)
    func userChangedName(to newName: String, controller: ReminderVesselEditTableViewController)
    func userChoseAddReminder(controller: ReminderVesselEditTableViewController)
    func userChose(reminder: Reminder, controller: ReminderVesselEditTableViewController)
}

class ReminderVesselEditTableViewController: UITableViewController {
    
    private enum Section: Int {
        case photo = 0, name, reminders
        static let count = 3
        var localizedTitle: String {
            switch self {
            case .photo:
                return "Photo"
            case .name:
                return "Name"
            case .reminders:
                return "Reminders"
            }
        }
    }
    
    weak var delegate: ReminderVesselEditTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(ReminderTableViewCell.nib, forCellReuseIdentifier: ReminderTableViewCell.reuseID)
        self.tableView.register(TextFieldTableViewCell.nib, forCellReuseIdentifier: TextFieldTableViewCell.reuseID)
        self.tableView.register(OptionalAddButtonTableViewHeaderFooterView.nib, forHeaderFooterViewReuseIdentifier: OptionalAddButtonTableViewHeaderFooterView.reuseID)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 40
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
            return self.delegate?.vessel.reminders.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { assertionFailure("Unknown Section"); return UITableViewCell(); }
        switch section {
        case .name:
            let id = TextFieldTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? TextFieldTableViewCell
            cell?.setTextField(text: self.delegate?.vessel.displayName)
            cell?.setPlaceHolder(label: nil, textField: "Plant Name")
            cell?.textChanged = { [unowned self] newName in
                self.delegate?.userChangedName(to: newName, controller: self)
            }
            return _cell
        case .photo:
            let id = ReminderVesselIconTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderVesselIconTableViewCell
            cell?.configure(with: self.delegate?.vessel.icon)
            cell?.iconButtonTapped = { [unowned self] in self.delegate?.userChosePhotoChange(controller: self) }
            return _cell
        case .reminders:
            let id = ReminderTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderTableViewCell
            cell?.configure(with: self.delegate?.vessel.reminders[indexPath.row])
            return _cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { assertionFailure("Unknown Section"); return; }
        switch section {
        case .name, .photo:
            break // ignore
        case .reminders:
            guard let vessel = self.delegate?.vessel.reminders[indexPath.row] else { return }
            self.delegate?.userChose(reminder: vessel, controller: self)
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { assertionFailure("Unknown Section"); return nil; }
        return section.localizedTitle
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    deinit {
        log.debug()
    }
}

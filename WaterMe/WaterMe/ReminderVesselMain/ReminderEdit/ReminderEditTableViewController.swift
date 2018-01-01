//
//  ReminderEditTableViewController.swift
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
import UIKit

class ReminderEditTableViewController: UITableViewController {
    
    var reminder: (() -> Result<Reminder, RealmError>?)?
    var kindChanged: ((Reminder.Kind, Bool) -> Void)?
    var intervalChosen: (() -> Void)?
    var noteChanged: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(TextViewTableViewCell.nib, forCellReuseIdentifier: TextViewTableViewCell.reuseID)
        self.tableView.register(TextFieldTableViewCell.nib, forCellReuseIdentifier: TextFieldTableViewCell.reuseID)
        self.tableView.register(ReminderKindTableViewCell.self, forCellReuseIdentifier: ReminderKindTableViewCell.reuseID)
        self.tableView.register(ReminderIntervalTableViewCell.self, forCellReuseIdentifier: ReminderIntervalTableViewCell.reuseID)
        self.tableView.register(LastPerformedTableViewCell.self, forCellReuseIdentifier: LastPerformedTableViewCell.reuseID)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reminder = self.reminder?()?.value else { assertionFailure("Missing Reminder Object"); return; }
        let section = Section(section: indexPath.section, for: reminder.kind)
        switch section {
        case .kind:
            self.tableView.deselectRow(at: indexPath, animated: true)
            // let the deslection happen before changing the tableview
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                let new = Reminder.Kind(row: indexPath.row)
                self.kindChanged?(new, false)
            }
        case .interval:
            self.intervalChosen?()
        default:
            break // ignore
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let reminder = self.reminder?()?.value else { return 0 }
        return Section.count(for: reminder.kind)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reminder = self.reminder?()?.value else { assertionFailure("Missing Reminder Object"); return 0; }
        let section = Section(section: section, for: reminder.kind)
        return section.numberOfRows(for: reminder.kind)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reminder = self.reminder?()?.value else { assertionFailure("Missing Reminder Object"); return UITableViewCell(); }
        let section = Section(section: indexPath.section, for: reminder.kind)
        switch section {
        case .kind:
            let id = ReminderKindTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderKindTableViewCell
            cell?.configure(rowNumber: indexPath.row, compareWith: reminder.kind)
            return _cell
        case .details:
            let id = TextFieldTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? TextFieldTableViewCell
            cell?.configure(with: reminder.kind)
            cell?.textChanged = { [unowned self] newText in
                self.updated(text: newText, for: reminder.kind)
            }
            return _cell
        case .interval:
            let id = ReminderIntervalTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderIntervalTableViewCell
            cell?.configure(with: reminder.interval)
            return _cell
        case .notes:
            let id = TextViewTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? TextViewTableViewCell
            cell?.configure(with: reminder.note)
            cell?.textChanged = { [unowned self] newText in
                self.noteChanged?(newText)
            }
            return _cell
        case .performed:
            let id = LastPerformedTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? LastPerformedTableViewCell
            cell?.configureWith(lastPerformedDate: reminder.performed.last?.date)
            return _cell
        }
    }
    
    func nameTextFieldBecomeFirstResponder() {
        guard let reminder = self.reminder?()?.value else { assertionFailure("Missing Reminder Object"); return; }
        let reminderKind = reminder.kind
        switch reminderKind {
        case .other, .move:
            let indexPath = IndexPath(row: 0, section: 1)
            UIView.animate(withDuration: UIApplication.style_animationDurationNormal, animations: {
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }, completion: { _ in
                let cell = self.tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell
                cell?.textFieldBecomeFirstResponder()
            })
        case .fertilize, .water:
            assertionFailure("Water and Fertilize Reminders don't have a textfield to select")
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(false)
    }
    
    private func updated(text newText: String, for oldKind: Reminder.Kind) {
        let newKind: Reminder.Kind
        defer {
            self.kindChanged?(newKind, true)
        }
        switch oldKind {
        case .move:
            newKind = Reminder.Kind.move(location: newText)
        case .other:
            newKind = Reminder.Kind.other(description: newText)
        default:
            fatalError("Wrong Kind Encountered")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let reminder = self.reminder?()?.value else { assertionFailure("Missing Reminder Object"); return nil; }
        let section = Section(section: section, for: reminder.kind)
        return section.localizedString
    }
    
    private enum Section {
        case kind, details, interval, notes, performed
        static func count(for kind: Reminder.Kind) -> Int {
            switch kind {
            case .fertilize, .water:
                return 4
            case .other, .move:
                return 5
            }
        }
        // swiftlint:disable:next cyclomatic_complexity
        init(section: Int, for kind: Reminder.Kind) {
            switch kind {
            case .fertilize, .water:
                switch section {
                case 0:
                    self = .kind
                case 1:
                    self = .interval
                case 2:
                    self = .notes
                case 3:
                    self = .performed
                default:
                    fatalError("Invalid Section")
                }
            case .other, .move:
                switch section {
                case 0:
                    self = .kind
                case 1:
                    self = .details
                case 2:
                    self = .interval
                case 3:
                    self = .notes
                case 4:
                    self = .performed
                default:
                    fatalError("Invalid Section")
                }
            }
        }
        var localizedString: String {
            switch self {
            case .kind:
                return ReminderEditViewController.LocalizedString.sectionTitleKind
            case .details:
                return ReminderEditViewController.LocalizedString.sectionTitleDetails
            case .interval:
                return ReminderEditViewController.LocalizedString.sectionTitleInterval
            case .notes:
                return ReminderEditViewController.LocalizedString.sectionTitleNotes
            case .performed:
                return ReminderEditViewController.LocalizedString.sectionTitleLastPerformed
            }
        }
        func numberOfRows(for kind: Reminder.Kind) -> Int {
            switch self {
            case .kind:
                return type(of: kind).count
            case .details, .performed, .interval, .notes:
                return 1
            }
        }
    }
}

fileprivate extension TextFieldTableViewCell {
    func configure(with kind: Reminder.Kind) {
        switch kind {
        case .move(let location):
            self.setLabelText(ReminderEditViewController.LocalizedString.dataEntryLabelMove,
                              andTextFieldPlaceHolderText: ReminderEditViewController.LocalizedString.dataEntryPlaceholderMove)
            self.setTextField(text: location)
        case .other(let description):
            self.setLabelText(ReminderEditViewController.LocalizedString.dataEntryLabelDescription,
                              andTextFieldPlaceHolderText: ReminderEditViewController.LocalizedString.dataEntryPlaceholderDescription)
            self.setTextField(text: description)
        default:
            let error = "Unsupported Kind: \(kind)"
            log.error(error)
            assertionFailure(error)
        }
    }
}

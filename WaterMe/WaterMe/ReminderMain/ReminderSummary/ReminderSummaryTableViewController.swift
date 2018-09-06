//
//  ReminderSummaryTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/4/18.
//  Copyright © 2018 Saturday Apps.
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

import UIKit
import WaterMeData
import RealmSwift
import Result

protocol ReminderSummaryTableViewControllerDelegate: class {
    var reminderResult: Result<Reminder, RealmError>! { get }
    func userChose(action: ReminderSummaryViewController.Action, within: ReminderSummaryTableViewController)
}

class ReminderSummaryTableViewController: UITableViewController {

    weak var delegate: ReminderSummaryTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(TransparentTableViewHeaderFooterView.self,
                                forHeaderFooterViewReuseIdentifier: TransparentTableViewHeaderFooterView.reuseID)
        self.tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.numberOfSections(withNote: self.reminderHasNote)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.numberOfRows(inSection: section, withNote: self.reminderHasNote)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 8
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: TransparentTableViewHeaderFooterView.reuseID)
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = Sections(indexPath, withNote: self.reminderHasNote)
        switch section {
        case .imageEmoji:
            return nil
        case .note:
            return nil
        case .actions, .cancel:
            return indexPath
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = Sections(indexPath, withNote: self.reminderHasNote)
        switch section {
        case .imageEmoji, .note:
            fatalError()
        case .actions(let row):
            switch row {
            case .editReminder:
                self.delegate?.userChose(action: .editReminder, within: self)
            case .editReminderVessel:
                self.delegate?.userChose(action: .editReminderVessel, within: self)
            case .performReminder:
                self.delegate?.userChose(action: .performReminder, within: self)
            }
        case .cancel:
            self.delegate?.userChose(action: .cancel, within: self)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Sections(indexPath, withNote: self.reminderHasNote)
        switch section {
        case .imageEmoji:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderVesselIconTableViewCell.reuseID,
                                                     for: indexPath) as! ReminderVesselIconTableViewCell
            cell.configure(with: self.delegate?.reminderResult.value?.vessel?.icon)
            return cell
        case .note:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! ButtonTableViewCell
            cell.locationInGroup = .alone
            cell.label?.attributedText =
                NSAttributedString(string: self.delegate?.reminderResult.value?.note ?? "",
                                   style: .migratorBody)
            return cell
        case .actions(let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ButtonTableViewCell
            switch row {
            case .performReminder:
                cell.locationInGroup = .top
                cell.label?.attributedText =
                    NSAttributedString(string: ReminderMainViewController.LocalizedString.buttonTitleReminderPerform,
                                       style: .reminderSummaryActionButton)
            case .editReminder:
                cell.locationInGroup = .middle
                cell.label?.attributedText =
                    NSAttributedString(string: UIApplication.LocalizedString.editReminder,
                                       style: .reminderSummaryActionButton)
            case .editReminderVessel:
                cell.locationInGroup = .bottom
                cell.label?.attributedText =
                    NSAttributedString(string: UIApplication.LocalizedString.editVessel,
                                       style: .reminderSummaryActionButton)
            }
            return cell
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CancelCell", for: indexPath) as! ButtonTableViewCell
            cell.label?.attributedText =
                NSAttributedString(string: UIAlertController.LocalizedString.buttonTitleCancel,
                                   style: .reminderSummaryCancelButton)
            cell.locationInGroup = .alone
            return cell
        }
    }
}

extension ReminderSummaryTableViewController {

    var reminderHasNote: Bool {
        return self.delegate?.reminderResult.value?.note != nil
    }

    private enum Sections {
        case imageEmoji
        case note
        case actions(ActionRows)
        case cancel

        static func numberOfSections(withNote: Bool) -> Int {
            return withNote ? 4 : 3
        }
        static func numberOfRows(inSection section: Int, withNote: Bool) -> Int {
            if withNote {
                switch section {
                case 0:
                    return 1
                case 1:
                    return 1
                case 2:
                    return ActionRows.allCases.count
                case 3:
                    return 1
                default:
                    fatalError()
                }
            } else {
                switch section {
                case 0:
                    return 1
                case 1:
                    return ActionRows.allCases.count
                case 2:
                    return 1
                default:
                    fatalError()
                }
            }
        }

        init(_ indexPath: IndexPath, withNote: Bool) {
            if withNote {
                switch (indexPath.section, indexPath.row) {
                case (0, _):
                    self = .imageEmoji
                case (1, _):
                    self = .note
                case (2, _):
                    self = .actions(ActionRows(rawValue: indexPath.row)!)
                case (3, _):
                    self = .cancel
                default:
                    fatalError()
                }
            } else {
                switch (indexPath.section, indexPath.row) {
                case (0, _):
                    self = .imageEmoji
                case (1, _):
                    self = .actions(ActionRows(rawValue: indexPath.row)!)
                case (2, _):
                    self = .cancel
                default:
                    fatalError()
                }
            }
        }
    }

    private enum ActionRows: Int, CaseIterable {
        case performReminder, editReminder, editReminderVessel
    }
}

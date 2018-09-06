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

class ReminderSummaryTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(TransparentTableViewHeaderFooterView.self,
                                forHeaderFooterViewReuseIdentifier: TransparentTableViewHeaderFooterView.reuseID)
        self.tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: TransparentTableViewHeaderFooterView.reuseID)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Sections(indexPath)
        switch section {
        case .imageEmoji:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReminderVesselIconTableViewCell.reuseID,
                                                     for: indexPath) as! ReminderVesselIconTableViewCell
            cell.configure(with: ReminderVessel.Icon.emoji("🤷‍♀️"))
            return cell
        case .actions(let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ButtonTableViewCell
            cell.label?.attributedText = NSAttributedString(string: "Do Me Please!",
                                                            style: .reminderSummaryActionButton)
            switch row {
            case .performReminder:
                cell.locationInGroup = .top
            case .editReminder:
                cell.locationInGroup = .middle
            case .editReminderVessel:
                cell.locationInGroup = .bottom
            }
            return cell
        case .cancel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CancelCell", for: indexPath) as! ButtonTableViewCell
            cell.label?.attributedText = NSAttributedString(string: "Cancel",
                                                            style: .reminderSummaryCancelButton)
            cell.locationInGroup = .alone
            return cell
        }
    }
}

extension ReminderSummaryTableViewController {
    private enum Sections {
        case imageEmoji
        case actions(ActionRows)
        case cancel

        static let numberOfSections = 3
        static func numberOfRows(inSection section: Int) -> Int {
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

        init(_ indexPath: IndexPath) {
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

    private enum ActionRows: Int, CaseIterable {
        case performReminder, editReminder, editReminderVessel
    }
}

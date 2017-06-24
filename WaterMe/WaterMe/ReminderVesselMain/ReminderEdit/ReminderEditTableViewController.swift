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

import WaterMeData
import UIKit

class ReminderEditTableViewController: UITableViewController {
    
    var reminder: (() -> Reminder)?
    var kindChanged: ((Reminder.Kind) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(TextFieldTableViewCell.nib, forCellReuseIdentifier: TextFieldTableViewCell.reuseID)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reminder = self.reminder?() else { assertionFailure("Missing Reminder Object"); return; }
        let section = Section(section: indexPath.section, for: reminder.kind)
        switch section {
        case .kind:
            self.tableView.deselectRow(at: indexPath, animated: true)
            // let the deslection happen before changing the tableview
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                let new = Reminder.Kind(row: indexPath.row)
                self.kindChanged?(new)
            }
        default:
            break // ignore
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let reminder = self.reminder?() else { assertionFailure("Missing Reminder Object"); return 0; }
        return Section.count(for: reminder.kind)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reminder = self.reminder?() else { assertionFailure("Missing Reminder Object"); return 0; }
        let section = Section(section: section, for: reminder.kind)
        return section.numberOfRows(for: reminder.kind)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reminder = self.reminder?() else { assertionFailure("Missing Reminder Object"); return UITableViewCell(); }
        let section = Section(section: indexPath.section, for: reminder.kind)
        switch section {
        case .kind:
            let id = ReminderKindTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderKindTableViewCell
            cell?.configure(rowNumber: indexPath.row, compareWith: reminder.kind)
            return _cell
        case .details:
            return UITableViewCell()
        case .interval:
            return UITableViewCell()
        case .performed:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let reminder = self.reminder?() else { assertionFailure("Missing Reminder Object"); return nil; }
        let section = Section(section: section, for: reminder.kind)
        return section.localizedString
    }
    
    private enum Section {
        case kind, details, interval, performed
        static func count(for kind: Reminder.Kind) -> Int {
            switch kind {
            case .fertilize, .water:
                return 3
            case .other, .move:
                return 4
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
                    self = .performed
                default:
                    fatalError("Invalid Section")
                }
            }
        }
        var localizedString: String {
            switch self {
            case .kind:
                return "Kind of Reminder"
            case .details:
                return "Details"
            case .interval:
                return "Remind Every"
            case .performed:
                return "Last Performed"
            }
        }
        func numberOfRows(for kind: Reminder.Kind) -> Int {
            switch self {
            case .kind:
                return type(of: kind).count
            case .details:
                switch kind {
                case .fertilize, .water:
                    fatalError("Invalid Section")
                case .move:
                    return 1
                case .other:
                    return 2
                }
            case .performed, .interval:
                return 1
            }
        }
    }
}

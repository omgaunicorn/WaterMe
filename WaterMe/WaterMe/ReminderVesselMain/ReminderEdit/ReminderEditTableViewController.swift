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
        guard let section = Section(rawValue: indexPath.section) else { assertionFailure("Unknown Section"); return; }
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
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { assertionFailure("Unknown Section"); return 0; }
        switch section {
        case .kind:
            return Reminder.Kind.count
        case .details:
            return 0
        case .interval:
            return 0
        case .performed:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { assertionFailure("Unknown Section"); return UITableViewCell(); }
        switch section {
        case .kind:
            let id = "ReminderKindTableViewCell"
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderKindTableViewCell
            cell?.configure(rowNumber: indexPath.row, compareWith: self.reminder?().kind)
            return _cell
        case .details:
            fatalError()
        case .interval:
            fatalError()
        case .performed:
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { assertionFailure("Unknown Section"); return nil; }
        return section.localizedString
    }
    
    private enum Section: Int {
        case kind, details, interval, performed
        static let count = 4
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
    }
    
}

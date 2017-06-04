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

class ReminderVesselEditTableViewController: UITableViewController {
    
    private enum Section: Int {
        case photo = 0, name
        static let count = 2
        var localizedTitle: String {
            switch self {
            case .photo:
                return "Photo"
            case .name:
                return "Name"
            }
        }
    }
    
    var editableFromDataSource: (() -> ReminderVessel.Editable)?
    var choosePhotoTapped: (() -> Void)? {
        didSet {
            // if this is changed, we need to make sure the cell gets the new closure
            guard self.isViewLoaded else { return }
            self.tableView.reloadData()
        }
    }
    var displayNameChanged: ((String) -> Void)? {
        didSet {
            // if this is changed, we need to make sure the cell gets the new closure
            guard self.isViewLoaded else { return }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { assert(false); return 0; }
        switch section {
        case .name:
            return 1
        case .photo:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { assert(false); return UITableViewCell(); }
        switch section {
        case .name:
            let id = TextFieldTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? TextFieldTableViewCell
            cell?.setTextField(text: self.editableFromDataSource?().displayName)
            cell?.textChanged = self.displayNameChanged
            return _cell
        case .photo:
            let id = ReminderVesselIconTableViewCell.reuseID
            let _cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            let cell = _cell as? ReminderVesselIconTableViewCell
            cell?.configure(with: self.editableFromDataSource?().icon)
            cell?.iconButtonTapped = self.choosePhotoTapped
            return _cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { assert(false); return nil; }
        return section.localizedTitle
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    deinit {
        log.debug()
    }
}

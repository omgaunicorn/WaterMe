//
//  ReminderSummaryTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/4/18.
//  Copyright © 2018 Saturday Apps. All rights reserved.
//

import UIKit
import WaterMeData

class ReminderSummaryTableViewController: UITableViewController {

    private enum Sections: Int, CaseIterable {
        case imageEmoji
    }

    private enum ImageEmojiRows: Int, CaseIterable {
        case imageEmoji
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { assertionFailure(); return 0; }
        switch section {
        case .imageEmoji:
            return ImageEmojiRows.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Sections(rawValue: indexPath.section) else { fatalError() }
        switch section {
        case .imageEmoji:
            guard let row = ImageEmojiRows(rawValue: indexPath.row) else { fatalError() }
            switch row {
            case .imageEmoji:
                let cell = tableView.dequeueReusableCell(withIdentifier: ReminderVesselIconTableViewCell.reuseID, for: indexPath) as! ReminderVesselIconTableViewCell
                cell.configure(with: ReminderVessel.Icon.emoji("🤷‍♀️"))
                return cell
            }
        }
    }

}

//
//  SettingsTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/1/18.
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

import UIKit

class SettingsTableViewController: UITableViewController {

    var settingsRowChosen: ((SettingsRows, ((Bool) -> Void)?) -> Void)?
    var tipJarRowChosen: ((TipJarRows, ((Bool) -> Void)?) -> Void)?
    var prices = TipJarPrices() {
        didSet {
            self.tableView.reloadSections(IndexSet([Sections.tipJar.rawValue]), with: .automatic)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false
        self.tableView.register(SimpleLabelTableViewCell.self, forCellReuseIdentifier: SimpleLabelTableViewCell.reuseID)
        self.tableView.register(SettingsTipJarTableViewCell.self, forCellReuseIdentifier: SettingsTipJarTableViewCell.reuseID)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { assertionFailure("Wrong Section"); return 0 }
        switch section {
        case .settings:
            return SettingsRows.count
        case .tipJar:
            return TipJarRows.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let (_, row) = Sections.sectionsAndRows(from: indexPath) else { fatalError("Wrong Section/Row") }
        switch row {
        case .left(let row):
            let _cell = tableView.dequeueReusableCell(withIdentifier: SimpleLabelTableViewCell.reuseID, for: indexPath)
            guard let cell = _cell as? SimpleLabelTableViewCell else { return _cell }
            cell.label.attributedText = NSAttributedString(string: row.localizedTitle, style: .selectableTableViewCell)
            cell.accessoryType = .disclosureIndicator
            return cell
        case .right(let row):
            let _cell = tableView.dequeueReusableCell(withIdentifier: SettingsTipJarTableViewCell.reuseID, for: indexPath)
            guard let cell = _cell as? SettingsTipJarTableViewCell else { return _cell }
            cell.configure(with: row, price: self.prices.price(for: row))
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Sections(rawValue: section) else { assertionFailure("Wrong Section"); return nil; }
        return section.localizedTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let (_, row) = Sections.sectionsAndRows(from: indexPath) else { fatalError("Wrong Section/Row") }
        let completion: ((Bool) -> Void)? = { tableView.deselectRow(at: indexPath, animated: $0) }
        switch row {
        case .left(let row):
            self.settingsRowChosen?(row, completion)
        case .right(let row):
            self.tipJarRowChosen?(row, completion)
        }
    }
}

extension SettingsTableViewController {
    fileprivate enum Sections: Int {
        static let count = 2
        case settings, tipJar
        var localizedTitle: String {
            switch self {
            case .settings:
                return SettingsMainViewController.LocalizedString.title
            case .tipJar:
                return SettingsMainViewController.LocalizedString.sectionTitleTipJar
            }
        }
        static func sectionsAndRows(from indexPath: IndexPath) -> (Sections, Either<SettingsRows, TipJarRows>)? {
            guard let section = Sections(rawValue: indexPath.section) else { assertionFailure("Wrong Section"); return nil; }
            switch section {
            case .settings:
                guard let rows = SettingsRows(rawValue: indexPath.row) else { assertionFailure("Wrong Rows"); return nil; }
                return (section, .left(rows))
            case .tipJar:
                guard let rows = TipJarRows(rawValue: indexPath.row) else { assertionFailure("Wrong Rows"); return nil; }
                return (section, .right(rows))
            }
        }
    }

    enum SettingsRows: Int {
        static let count = 2
        case openSettings, emailDeveloper
        var localizedTitle: String {
            switch self {
            case .openSettings:
                return SettingsMainViewController.LocalizedString.cellTitleOpenSettings
            case .emailDeveloper:
                return SettingsMainViewController.LocalizedString.cellTitleEmailDeveloper
            }
        }
    }

    enum TipJarRows: Int {
        static let count = 4
        case free, small, medium, large
        var localizedTitle: String {
            switch self {
            case .free:
                return SettingsMainViewController.LocalizedString.cellTitleTipJarFree
            case .small:
                return SettingsMainViewController.LocalizedString.cellTitleTipJarSmall
            case .medium:
                return SettingsMainViewController.LocalizedString.cellTitleTipJarMedium
            case .large:
                return SettingsMainViewController.LocalizedString.cellTitleTipJarLarge
            }
        }
    }

    struct TipJarPrices {
        var small: String?
        var medium: String?
        var large: String?
        init() {
            self.small = nil
            self.medium = nil
            self.large = nil
        }
        func price(for row: TipJarRows) -> String? {
            switch row {
            case .free:
                return "Free"
            case .small:
                return self.small
            case .medium:
                return self.medium
            case .large:
                return self.large
            }
        }
    }
}

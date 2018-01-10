//
//  SettingsMainViewController.swift
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

class SettingsMainViewController: UIViewController {

    typealias Completion = ((UIViewController) -> Void)

    class func newVC(completion: Completion?) -> UIViewController {
        let sb = UIStoryboard(name: "Settings", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        let vc = navVC.viewControllers.first as! SettingsMainViewController
        vc.completionHandler = completion
        return navVC
    }

    /*@IBOutlet*/ private weak var tableViewController: SettingsTableViewController?
    private var completionHandler: Completion?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LocalizedString.title

        self.tableViewController?.settingsRowChosen = { [unowned self] chosen, deselectRowAnimated in
            switch chosen {
            case .emailDeveloper:
                let vc = EmailDeveloperViewController.newVC() { vc in
                    guard let vc = vc else { deselectRowAnimated?(true); return; }
                    vc.dismiss(animated: true, completion: { deselectRowAnimated?(true) })
                }
                self.present(vc, animated: true, completion: nil)
            case .openSettings:
                UIApplication.shared.openSettings(completion: { _ in deselectRowAnimated?(true) })
            }
        }
    }

    @IBAction private func doneButtonTapped(_ sender: Any) {
        self.completionHandler?(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let settingsVC = segue.destination as? SettingsTableViewController {
            self.tableViewController = settingsVC
        }
    }
}

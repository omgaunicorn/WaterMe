//
//  ReminderVesselEditViewController.swift
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
//  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

class ReminderVesselEditViewController: UIViewController {
    
    class func newVC() -> UIViewController {
        let sb = UIStoryboard(name: "ReminderVesselEdit", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        _ = navVC.viewControllers.first as! ReminderVesselEditViewController
        return navVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New Plant"
    }
    
    @IBAction private func cancelButtonTapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func saveButtonTapped(_ sender: NSObject?) {
        log.debug()
    }
    
    deinit {
        log.debug()
    }
}

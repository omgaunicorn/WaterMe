//
//  ReminderEditViewController.swift
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

import UIKit

class ReminderEditViewController: UIViewController {
    
    class func newVC() -> UIViewController {
        let sb = UIStoryboard(name: "ReminderEdit", bundle: Bundle(for: self))
        let navVC = sb.instantiateInitialViewController()!
        return navVC
    }
    
    @IBOutlet private weak var deleteButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.deleteButton?.title = "Delete"
        
        log.debug()
    }
    
}

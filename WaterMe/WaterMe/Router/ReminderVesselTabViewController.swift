//
//  ReminderVesselTabViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 8/21/17.
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

class ReminderVesselTabViewController: UITabBarController {
    
    private let reminderMainViewControllerNavVC: UINavigationController
    private let reminderVesselMainViewControllerNavVC: UINavigationController
    private var reminderMainViewController: ReminderMainViewController {
        // swiftlint:disable:next force_cast
        return self.reminderMainViewControllerNavVC.viewControllers.first as! ReminderMainViewController
    }
    private var reminderVesselMainViewController: ReminderVesselMainViewController {
        // swiftlint:disable:next force_cast
        return self.reminderVesselMainViewControllerNavVC.viewControllers.first as! ReminderVesselMainViewController
    }
    
    init(basicController: BasicController, proController: ProController?) {
        let reminderVC = ReminderMainViewController.newVC(basicController: basicController, proController: proController)
        let vesselVC = ReminderVesselMainViewController.newVC(basicController: basicController, proController: proController)
        self.reminderMainViewControllerNavVC = reminderVC
        self.reminderVesselMainViewControllerNavVC = vesselVC
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure("This initalizer should not be used.")
        let basicRC = BasicController(kind: .local)
        let reminderVC = ReminderMainViewController.newVC(basicController: basicRC, proController: nil)
        let vesselVC = ReminderVesselMainViewController.newVC(basicController: basicRC, proController: nil)
        self.reminderMainViewControllerNavVC = reminderVC
        self.reminderVesselMainViewControllerNavVC = vesselVC
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [self.reminderVesselMainViewControllerNavVC, self.reminderMainViewControllerNavVC]
    }
    
}

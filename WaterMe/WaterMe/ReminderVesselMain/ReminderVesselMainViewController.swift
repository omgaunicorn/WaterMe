//
//  ReminderVesselMainViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/31/17.
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

import WaterMeData
import UIKit

class ReminderVesselMainViewController: UIViewController, HasProController, HasBasicController {

    class func newVC(basicController: BasicController, proController: ProController? = nil) -> UIViewController {
        let sb = UIStoryboard(name: "ReminderVesselMain", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderVesselMainViewController
        vc.configure(with: basicController)
        vc.configure(with: proController)
        return navVC
    }
    
    /*@IBOutlet*/ private weak var collectionVC: ReminderVesselCollectionViewController!
    
    var basicRC: BasicController?
    var proRC: ProController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("")
        
        self.collectionVC = self.childViewControllers.first()!
        self.collectionVC.configure(with: self.basicRC)
        
        self.title = "WaterMe"
    }
    
}

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
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

import WaterMeData
import UIKit

class ReminderVesselMainViewController: UIViewController, HasProController, HasBasicController {

    class func newVC(basicController: BasicController, proController: ProController? = nil) -> UINavigationController {
        let sb = UIStoryboard(name: "ReminderVesselMain", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let navVC = sb.instantiateInitialViewController() as! UINavigationController
        // swiftlint:disable:next force_cast
        var vc = navVC.viewControllers.first as! ReminderVesselMainViewController
        vc.title = "Manage Plants" // set here because it works better in UITabBarController
        vc.configure(with: basicController)
        vc.configure(with: proController)
        return navVC
    }
    
    /*@IBOutlet*/ private weak var collectionVC: ReminderVesselCollectionViewController?
    
    var basicRC: BasicController?
    var proRC: ProController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let data = self.collectionVC?.data, case .failure(let error) = data {
            self.collectionVC?.data = nil
            let alert = UIAlertController(error: error, completion: nil)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction private func addReminderVesselButtonTapped(_ sender: NSObject?) {
        self.editReminderVessel(nil)
    }
    
    private func editReminderVessel(_ vessel: ReminderVessel?) {
        guard let basicRC = self.basicRC else { return }
        let deselectAction: (() -> Void)? = vessel == nil ? nil : { self.collectionVC?.collectionView?.deselectAllItems(animated: true) }
        let editVC = ReminderVesselEditViewController.newVC(basicRC: basicRC, editVessel: vessel) { vc in
            vc.dismiss(animated: true, completion: deselectAction)
        }
        self.present(editVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var destVC = segue.destination as? ReminderVesselCollectionViewController {
            self.collectionVC = destVC
            destVC.vesselChosen = { [unowned self] in self.editReminderVessel($0) }
            destVC.configure(with: self.basicRC)
        }
    }
    
}

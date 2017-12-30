//
//  CoreDataMigratorViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 29/12/17.
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

class CoreDataMigratorViewController: UIViewController, HasBasicController {

    class func newVC(migrator: CoreDataMigrator, basicRC: BasicController, completion: @escaping (UIViewController) -> Void) -> UIViewController {
        let sb = UIStoryboard(name: "CoreDataMigration", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        var vc = sb.instantiateInitialViewController() as! CoreDataMigratorViewController
        vc.completionHandler = completion
        vc.configure(with: basicRC)
        vc.migrator = migrator
        return vc
    }

    private var completionHandler: ((UIViewController) -> Void)!
    private var migrator: CoreDataMigrator!
    var basicRC: BasicController?

}

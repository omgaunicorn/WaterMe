//
//  PurchaseThanksViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 14/1/18.
//  Copyright © 2018 Saturday Apps.
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

import Cheers
import WaterMeStore
import UIKit

class PurchaseThanksViewController: UIViewController {

    class func newVC(inFlight: InFlightTransaction?, completion: @escaping (UIViewController) -> Void) -> UIViewController {
        let sb = UIStoryboard(name: "PurchaseThanks", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ModalParentViewController
        vc.configureChild = { vc in
            // swiftlint:disable:next force_cast
            var vc = vc as! PurchaseThanksViewController
        }
        return vc
    }

    @IBOutlet private weak var contentView: UIView!

    private let cheerView: CheerView = {
        let v = CheerView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.layer.cornerRadius = UIApplication.style_cornerRadius
        self.contentView.addSubview(self.cheerView)
        self.contentView.addConstraints([
            self.contentView.leadingAnchor.constraint(equalTo: self.cheerView.leadingAnchor, constant: 0),
            self.contentView.trailingAnchor.constraint(equalTo: self.cheerView.trailingAnchor, constant: 0),
            self.cheerView.heightAnchor.constraint(equalToConstant: 1)
            ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.cheerView.start()
    }
    
}

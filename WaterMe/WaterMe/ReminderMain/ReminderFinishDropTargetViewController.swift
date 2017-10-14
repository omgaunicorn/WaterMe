//
//  ReminderFinishDropTargetViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 13/10/17.
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

class ReminderFinishDropTargetViewController: UIViewController, HasBasicController, HasProController {

    @IBOutlet private weak var dropTargetView: UIView?

    var proRC: ProController?
    var basicRC: BasicController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dropTargetView?.addInteraction(UIDropInteraction(delegate: self))
    }
    
}

extension ReminderFinishDropTargetViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        print("interested")
        return true
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let prop = UIDropProposal(operation: .copy)
        return prop
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print("perform")
    }

    func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
        print("concluded")
    }
}

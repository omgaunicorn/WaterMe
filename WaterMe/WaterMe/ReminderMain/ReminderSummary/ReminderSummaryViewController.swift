//
//  ReminderSummaryViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/4/18.
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

import UIKit

class ReminderSummaryViewController: UIViewController {

    enum Action {
        case cancel, performReminder, editReminderVessel, editReminder
    }

    typealias Completion = (Action, UIViewController) -> Void

    class func newVC(completion: @escaping Completion) -> UIViewController {
        let sb = UIStoryboard(name: "ReminderSummary", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ReminderSummaryViewController
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.popoverBackgroundViewClass = ReminderSummaryPopoverBackgroundView.self
        vc.completion = completion
        return vc
    }

    private var _preferredContentSize = CGSize(width: 320, height: 320)
    override var preferredContentSize: CGSize {
        get { return _preferredContentSize }
        set { _preferredContentSize = newValue }
    }

    private weak var tableViewController: ReminderSummaryTableViewController?
    private var completion: Completion?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ReminderSummaryTableViewController {
            self.tableViewController = dest
            dest.delegate = self
        }
    }
}

extension ReminderSummaryViewController: ReminderSummaryTableViewControllerDelegate {
    func userChose(action: ReminderSummaryViewController.Action, within: ReminderSummaryTableViewController) {
        self.completion?(action, self)
    }
}

extension ReminderSummaryViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.completion?(.cancel, self)
        return false
    }
}

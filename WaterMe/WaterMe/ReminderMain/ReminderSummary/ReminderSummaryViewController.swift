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
import WaterMeData
import Result
import RealmSwift

class ReminderSummaryViewController: UIViewController {

    typealias Completion = (Action, Reminder.Identifier, UIViewController) -> Void
    enum Action {
        case cancel, performReminder, editReminderVessel, editReminder
    }

    class func newVC(reminderID: Reminder.Identifier,
                     basicController: BasicController,
                     sourceView: UIView,
                     completion: @escaping Completion) -> UIViewController
    {
        let sb = UIStoryboard(name: "ReminderSummary", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ReminderSummaryViewController
        // configure presentation
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.popoverBackgroundViewClass = ReminderSummaryPopoverBackgroundView.self
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = UIAlertController.sourceRect(from: sourceView)
        // configure needed properties
        vc.completion = completion
        vc.reminderResult = basicController.reminder(matching: reminderID)
        vc.reminderID = reminderID
        return vc
    }

    @IBOutlet private weak var darkBackgroundView: UIView?
    private var isPresentedAsPopover = false
    @IBOutlet var tableViewControllerLeadingTrailingConstraints: [NSLayoutConstraint]?
    private var tableViewControllerEdgeInsets: UIEdgeInsets {
        let number = self.tableViewControllerLeadingTrailingConstraintConstant
        return UIEdgeInsets(top: 0, left: 0, bottom: number, right: 0)
    }
    private var tableViewControllerLeadingTrailingConstraintConstant: CGFloat {
        switch self.isPresentedAsPopover {
        case true:
            return 0
        case false:
            return 8
        }
    }
    private var darkBackgroundViewAlpha: CGFloat {
        switch self.isPresentedAsPopover {
        case true:
            return 0
        case false:
            return 1
        }
    }

    private var _preferredContentSize = CGSize(width: 320, height: 1024)
    override var preferredContentSize: CGSize {
        get { return _preferredContentSize }
        set { _preferredContentSize = newValue }
    }

    var reminderResult: Result<Reminder, RealmError>!
    private var completion: Completion!
    private var reminderID: Reminder.Identifier!
    private weak var tableViewController: ReminderSummaryTableViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.notificationToken = self.reminderResult?.value?.observe({ [weak self] in self?.reminderChanged($0) })
        self.darkBackgroundView?.alpha = 0
        self.tableViewController!.tableView!.contentInset = self.tableViewControllerEdgeInsets
        self.tableViewController!.tableView!.scrollIndicatorInsets = self.tableViewControllerEdgeInsets
        self.tableViewControllerLeadingTrailingConstraints!.forEach() { c in
            c.constant = self.tableViewControllerLeadingTrailingConstraintConstant
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.style_animateNormal() {
            self.darkBackgroundView?.alpha = self.darkBackgroundViewAlpha
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.darkBackgroundView?.alpha = self.darkBackgroundViewAlpha
            self.tableViewController!.tableView!.contentInset = self.tableViewControllerEdgeInsets
            self.tableViewController!.tableView!.scrollIndicatorInsets = self.tableViewControllerEdgeInsets
            self.tableViewControllerLeadingTrailingConstraints!.forEach() { c in
                c.constant = self.tableViewControllerLeadingTrailingConstraintConstant
            }
        }, completion: nil)
    }

    private func reminderChanged(_ changes: ObjectChange) {
        switch changes {
        case .change:
            guard let reminder = self.reminderResult.value else { return }
            self.reminderID = Reminder.Identifier(reminder: reminder)
            self.tableViewController.tableView.reloadData()
        case .deleted, .error:
            self.completion(.cancel, self.reminderID, self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ReminderSummaryTableViewController {
            self.tableViewController = dest
            dest.delegate = self
        }
    }

    private var notificationToken: NotificationToken?
    deinit {
        self.notificationToken?.invalidate()
    }
}

extension ReminderSummaryViewController: ReminderSummaryTableViewControllerDelegate {
    func userChose(action: ReminderSummaryViewController.Action, within: ReminderSummaryTableViewController) {
        self.completion(action, self.reminderID, self)
    }
}

extension ReminderSummaryViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.completion(.cancel, self.reminderID, self)
        return false
    }

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        switch traitCollection.horizontalSizeClass {
        case .compact:
            self.isPresentedAsPopover = false
            return .overFullScreen
        case .regular, .unspecified:
            self.isPresentedAsPopover = true
            return controller.presentedViewController.modalPresentationStyle
        }
    }
}

//
//  ReminderSummaryViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/4/18.
//  Copyright © 2018 Saturday Apps. All rights reserved.
//

import UIKit

class ReminderSummaryViewController: UIViewController {

    typealias Completion = (UIViewController) -> Void

    class func newVC(completion: @escaping Completion) -> UIViewController {
        let sb = UIStoryboard(name: "ReminderSummary", bundle: Bundle(for: self))
        // swiftlint:disable:next force_cast
        let vc = sb.instantiateInitialViewController() as! ReminderSummaryViewController
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = vc
        vc.popoverPresentationController?.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        vc.completion = completion
        return vc
    }

    private var completion: Completion?

}

extension ReminderSummaryViewController: UIPopoverPresentationControllerDelegate {

    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        self.completion?(self)
        return false
    }

}

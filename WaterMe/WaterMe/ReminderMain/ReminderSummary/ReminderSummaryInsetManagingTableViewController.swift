//
//  ReminderSummaryInsetManagingTableViewController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/13/18.
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

class ReminderSummaryInsetManagingTableViewController: ReminderSummaryTableViewController {

    private var additionalSafeAreaInsetsDirty = true

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard self.additionalSafeAreaInsetsDirty == true else { return }
        self.additionalSafeAreaInsetsDirty = false
        self.updateAdditionalSafeAreaInsets()
        self.tableView.scrollToBottom(false)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.additionalSafeAreaInsets = .zero
        self.additionalSafeAreaInsetsDirty = true
        super.viewWillTransition(to: size, with: coordinator)
    }

    private func updateAdditionalSafeAreaInsets() {
        // get ready to configure the `additionalSafeAreaInsets` property
        var contentInsets: UIEdgeInsets?
        defer {
            self.additionalSafeAreaInsets = contentInsets ?? .zero
        }

        // if we're a popover, we're not doing any of this
        guard self.delegate?.isPresentedAsPopover == false else { return }

        // find out if we need to artifically "lower" the content to be bottom aligned
        _ = {
            guard self.tableView.allRowsVisible else { return }
            let safeAreaHeight = self.view.safeAreaLayoutGuide.layoutFrame.height
            let tableContentsHeight = self.tableView.visibleRowsSize.height
            guard safeAreaHeight > tableContentsHeight else { return }
            let diff = safeAreaHeight - tableContentsHeight
            contentInsets = UIEdgeInsets(top: diff,
                                         left: 0,
                                         bottom: 0,
                                         right: 0)
        }()

        // find out if the OS is already providing bottom insets
        _ = {
            let bottomInset = self.tableView.adjustedContentInset.bottom
            guard bottomInset == 0 else { return }
            if var existingInsets = contentInsets {
                existingInsets.top -= ReminderSummaryViewController.style_bottomPadding
                existingInsets.bottom += ReminderSummaryViewController.style_bottomPadding
                contentInsets = existingInsets
            } else {
                let top = ReminderSummaryViewController.style_topPadding
                let bottom = ReminderSummaryViewController.style_bottomPadding
                contentInsets = UIEdgeInsets(top: top,
                                             left: 0,
                                             bottom: bottom,
                                             right: 0)
            }
        }()
    }
}

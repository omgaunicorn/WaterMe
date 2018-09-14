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
        self.additionalSafeAreaInsets = self.calculateNeededInsets() ?? .zero
    }

    private func calculateNeededInsets() -> UIEdgeInsets? {
        // if we're a popover, we're not doing any of this
        guard self.delegate?.isPresentedAsPopover == false else { return nil }

        // get top and bottom insets
        let bottomInset = self.tableView.adjustedContentInset.bottom
        let topInset = self.tableView.adjustedContentInset.top
        let neededBottomInset = bottomInset == 0 ? ReminderSummaryViewController.style_bottomPadding : 0

        if let additionalTopInset = self.calculateTableViewHeightVsSafeAreaHeight() {
            // the top inset is specified by the table calculated
            // now we need to see if we need to use a bottom inset
            return UIEdgeInsets(top: additionalTopInset - neededBottomInset,
                                left: 0,
                                bottom: neededBottomInset,
                                right: 0)
        } else {
            // the tableview exceeds the size of the screen
            // now we need to check if we need top inset and include the bottom inset
            let neededTopInset = topInset == 0 ?
                ReminderSummaryViewController.style_bottomPadding :
                ReminderSummaryViewController.style_topPadding
            return UIEdgeInsets(top: neededTopInset,
                                left: 0,
                                bottom: neededBottomInset,
                                right: 0)
        }
    }

    private func calculateTableViewHeightVsSafeAreaHeight() -> CGFloat? {
        guard self.tableView.allRowsVisible else { return nil }
        let safeAreaHeight = self.view.safeAreaLayoutGuide.layoutFrame.height
        let tableContentsHeight = self.tableView.visibleRowsSize.height
        guard safeAreaHeight > tableContentsHeight else { return nil }
        return safeAreaHeight - tableContentsHeight
    }
}

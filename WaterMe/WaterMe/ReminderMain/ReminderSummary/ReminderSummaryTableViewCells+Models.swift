//
//  ReminderSummaryTableViewCells+Models.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 9/15/18.
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

import WaterMeData

extension ButtonTableViewCell {
    func configure(for action: ReminderSummaryTableViewController.ActionRows) {
        self.hairlineView?.backgroundColor = ReminderSummaryViewController.style_actionButtonSeparatorColor
        switch action {
        case .editReminder:
            self.locationInGroup = .middle
            self.label?.attributedText =
                NSAttributedString(string: UIApplication.LocalizedString.editReminder,
                                   style: .reminderSummaryActionButton)
        case .editReminderVessel:
            self.locationInGroup = .bottom
            self.label?.attributedText =
                NSAttributedString(string: UIApplication.LocalizedString.editVessel,
                                   style: .reminderSummaryActionButton)
        case .performReminder:
            self.locationInGroup = .top
            self.label?.attributedText =
                NSAttributedString(string: ReminderMainViewController.LocalizedString.buttonTitleReminderPerform,
                                   style: .reminderSummaryActionButton)
        }
    }
    
    func configureAsCancelButton() {
        self.label?.attributedText =
            NSAttributedString(string: UIAlertController.LocalizedString.buttonTitleCancel,
                               style: .reminderSummaryCancelButton)
        self.locationInGroup = .alone
    }
}

extension InfoTableViewCell {
    func configure(withNoteString noteString: String?) {
        self.locationInGroup = .alone
        self.label0?.attributedText =
            NSAttributedString(string: noteString ?? "",
                               style: .textInputTableViewCell)
        self.sublabel0?.attributedText =
            NSAttributedString(string: ReminderEditViewController.LocalizedString.sectionTitleNotes,
                               style: .reminderSummarySublabel)
    }
    
    func configureUnimportant(with reminder: Reminder?) {
        _ = {
            let vesselName = reminder?.vessel?.displayName
            let vesselNameStyle = vesselName != nil ?
                Style.reminderSummaryPrimaryLabel :
                Style.reminderSummaryPrimaryLabelValueNIL
            self.label0?.attributedText = NSAttributedString(string: vesselName ?? ReminderVessel.LocalizedString.untitledPlant,
                                                                      style: vesselNameStyle)
            self.sublabel0?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadPlantName,
                                                                         style: .reminderSummarySublabel)
        }()
        _ = {
            let lastPerformedDate = reminder?.performed.last?.date
            let dateString = self.timeAgoDateFormatter.timeAgoString(for: lastPerformedDate)
            self.label1?.attributedText = NSAttributedString(string: dateString,
                                                                           style: .reminderSummaryPrimaryLabel)
            self.sublabel1?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadLastPerformDate,
                                                                              style: .reminderSummarySublabel)
        }()
    }

    func configureImportant(with reminder: Reminder?) {
        _ = {
            guard let reminderName = reminder?.kind.localizedLongString else { return }
            self.label0?.attributedText = NSAttributedString(string: reminderName,
                                                             style: .reminderSummaryPrimaryLabel)
            self.sublabel0?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadReminderKind,
                                                                style: .reminderSummarySublabel)
        }()
        _ = {
            let nextPerformDate = reminder?.nextPerformDate ?? Date()
            let dueDateString = self.dueDateFormatter.string(from: nextPerformDate)
            self.label1?.attributedText = NSAttributedString(string: dueDateString,
                                                             style: .reminderSummaryPrimaryLabel)
            self.sublabel1?.attributedText = NSAttributedString(string: ReminderSummaryViewController.LocalizedString.subheadNextPerformDate,
                                                                style: .reminderSummarySublabel)
        }()
    }
}

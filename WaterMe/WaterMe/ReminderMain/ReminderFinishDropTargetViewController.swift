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

class ReminderFinishDropTargetViewController: UIViewController, HasBasicController, HasProController, UIDropInteractionDelegate {

    @IBOutlet private weak var dropTargetView: ReminderDropTargetView?

    var basicRC: BasicController?
    var proRC: ProController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dropTargetView?.addInteraction(UIDropInteraction(delegate: self))
    }

    // MARK: UIDropInteractionDelegate

    // Data Updates

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return !session.reminderDrags.isEmpty
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        guard self.dropTargetView?.hoverState != .drop else { return UIDropProposal(operation: .forbidden) }
        guard !session.reminderDrags.isEmpty else { return UIDropProposal(operation: .forbidden) }
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let results = self.basicRC?.appendNewPerformToReminders(with: session.reminderDrags) else { return }
        if case .failure(let error) = results {
            print("Display an error")
        }
    }

    // UI Updates

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        guard self.dropTargetView?.hoverState != .drop else { return }
        self.dropTargetView?.hoverState = .hover
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        guard self.dropTargetView?.hoverState != .drop else { return }
        self.dropTargetView?.hoverState = .noHover
    }

    func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
        self.dropTargetView?.hoverState = .drop
        print("Finished Watering: \(session.reminderDrags)")
    }

}

fileprivate extension UIDropSession {
    fileprivate var reminderDrags: [Reminder.Identifier] {
        return self.localDragSession?.items.flatMap({ $0.localObject as? Reminder.Identifier }) ?? []
    }
}

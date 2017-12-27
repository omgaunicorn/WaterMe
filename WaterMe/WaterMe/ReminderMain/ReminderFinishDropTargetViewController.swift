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

protocol ReminderFinishDropTargetViewControllerDelegate: class {
    func dropTargetView(willResizeHeightTo: CGFloat, from: ReminderFinishDropTargetViewController) -> (() -> Void)?
}

class ReminderFinishDropTargetViewController: UIViewController, HasBasicController, HasProController, UIDropInteractionDelegate {

    @IBOutlet private weak var dropTargetView: ReminderDropTargetView?
    @IBOutlet private weak var dropTargetViewHeightConstraint: NSLayoutConstraint?

    var basicRC: BasicController?
    var proRC: ProController?
    weak var delegate: ReminderFinishDropTargetViewControllerDelegate?
    var dropTargetViewHeight: CGFloat {
        return self.dropTargetViewHeightConstraint?.constant ?? 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dropTargetView?.addInteraction(UIDropInteraction(delegate: self))
        self.dropTargetView?.finishedPlayingDropVideo = { [unowned self] in
            self.updateDropTargetHeightForNotDragging(animated: true)
            self.dragInProgress = false
        }
    }

    // MARK: UIDropInteractionDelegate

    // Data Updates

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return !session.reminderDrags.isEmpty
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        guard !session.reminderDrags.isEmpty else { return UIDropProposal(operation: .forbidden) }
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        guard let results = self.basicRC?.appendNewPerformToReminders(with: session.reminderDrags) else { return }
        if case .failure(let error) = results {
            print("Display an error")
        }
    }

    // Handle resizes

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.dragInProgress == false {
            self.updateDropTargetHeightForNotDragging()
        }
    }

    private func updateDropTargetHeightForDragging(animated: Bool = false) {
        let changes: () -> Void = {
            let height = self.view.bounds.height
            self.dropTargetViewHeightConstraint?.constant = height
            let animateAlongSide = self.delegate?.dropTargetView(willResizeHeightTo: height, from: self)
            animateAlongSide?()
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: changes)
        } else {
            changes()
        }
    }

    private func updateDropTargetHeightForNotDragging(animated: Bool = false) {
        let verticalSizeClass = self.view.traitCollection.verticalSizeClass
        let changes: () -> Void = {
            let height: CGFloat
            switch verticalSizeClass {
            case .regular, .unspecified:
                height = 50
            case .compact:
                height = self.view.bounds.height
            }
            self.dropTargetViewHeightConstraint?.constant = height
            let animateAlongSide = self.delegate?.dropTargetView(willResizeHeightTo: height, from: self)
            animateAlongSide?()
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: changes)
        } else {
            changes()
        }
    }

    // UI Updates

    private var dragInProgress = false

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        self.dragInProgress = true
        self.updateDropTargetHeightForDragging(animated: true)
        guard self.dropTargetView?.hoverState != .drop else { return }
        self.dropTargetView?.hoverState = .hover
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        self.updateDropTargetHeightForNotDragging(animated: true)
        self.dragInProgress = false
        guard self.dropTargetView?.hoverState != .drop else { return }
        self.dropTargetView?.hoverState = .noHover
    }

    func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
        guard self.dropTargetView?.hoverState != .drop else { return }
        self.dropTargetView?.hoverState = .drop
    }
}

fileprivate extension UIDropSession {
    fileprivate var reminderDrags: [Reminder.Identifier] {
        return self.localDragSession?.items.flatMap({ $0.localObject as? Reminder.Identifier }) ?? []
    }
}

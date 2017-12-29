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
    func animateAlongSideDropTargetViewResize(within: ReminderFinishDropTargetViewController) -> (() -> Void)?
}

class ReminderFinishDropTargetViewController: UIViewController, HasBasicController, HasProController, UIDropInteractionDelegate {

    @IBOutlet private weak var instructionalView: DragTargetInstructionalView?
    @IBOutlet private weak var animationView: WateringAnimationPlayerView?
    @IBOutlet private weak var dropTargetView: UIView?
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
        self.animationView?.finishedPlayingDropVideo = { [unowned self] in
            self.updateDropTargetHeightForNotDragging(animated: true)
            self.isDragInProgress = false
        }
    }

    private var viewDidAppearOnce = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.viewDidAppearOnce == false {
            self.viewDidAppearOnce = true
            self.instructionalView?.performInstructionalAnimation(completion: nil)
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

    // Handle View Layouts

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // if we change size (rotate or ipad resize) and the video is not at the beginning,
        // just start it playing to the beginning
        guard self.animationView?.hoverState != .noHover else { return }
        self.animationView?.hoverState = .noHover
    }

    // Because the child View controller layout subviews and other layout methods get called AFTER the parent
    // I need this childVC to cause the collectionView from the parent to get its insets updated
    // Or else, during rotation, the parent VC sees the wrong height for the dropTargetView
    // kind of hacky, but I couldn't figure out a better way to do it.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.isDragInProgress == false {
            self.updateDropTargetHeightForNotDragging(animated: false)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewDidLayoutSubviews()

        if self.isDragInProgress == false {
            self.updateDropTargetHeightForNotDragging(animated: false)
        }
    }

    private func updateDropTargetHeightForDragging(animated: Bool) {
        let changes: () -> Void = {
            let height = self.view.bounds.height
            self.dropTargetViewHeightConstraint?.constant = height
            self.delegate?.animateAlongSideDropTargetViewResize(within: self)?()
        }

        guard animated == true else {
            changes()
            return
        }

        UIView.animate(withDuration: 0.3) {
            changes()
            self.view.layoutIfNeeded()
        }
    }

    private func updateDropTargetHeightForNotDragging(animated: Bool) {
        let verticalSizeClass = self.view.traitCollection.verticalSizeClass
        let changes: () -> Void = {
            let height: CGFloat
            switch verticalSizeClass {
            case .regular, .unspecified:
                height = type(of: self).style_dropTargetViewCompactHeight
            case .compact:
                height = self.view.bounds.height
            }
            self.dropTargetViewHeightConstraint?.constant = height
            self.delegate?.animateAlongSideDropTargetViewResize(within: self)?()
        }

        guard animated == true else {
            changes()
            return
        }

        UIView.animate(withDuration: 0.3) {
            changes()
            self.view.layoutIfNeeded()
        }
    }

    // UI Updates

    private var isDragInProgress = false

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        self.isDragInProgress = true
        self.updateDropTargetHeightForDragging(animated: true)
        guard self.animationView?.hoverState != .drop else { return }
        self.animationView?.hoverState = .hover
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        self.updateDropTargetHeightForNotDragging(animated: true)
        self.isDragInProgress = false
        guard self.animationView?.hoverState != .drop else { return }
        self.animationView?.hoverState = .noHover
    }

    func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession) {
        guard self.animationView?.hoverState != .drop else { return }
        self.animationView?.hoverState = .drop
    }
}

fileprivate extension UIDropSession {
    fileprivate var reminderDrags: [Reminder.Identifier] {
        return self.localDragSession?.items.flatMap({ $0.localObject as? Reminder.Identifier }) ?? []
    }
}

class OnlySubviewsTouchableView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchedView = super.hitTest(point, with: event)
        // if the deepest touchedview is myself, return NIL so it passes through
        guard touchedView !== self else { return nil }
        // otherwise just use the super value
        return touchedView
    }
}

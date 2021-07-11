//
//  CloudSyncProgressView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2021/05/04.
//  Copyright © 2021 Saturday Apps.
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
import Calculate
import Datum

class CloudSyncProgressView: ZStackView {
    
    /// Sends the progress view and a closure to complete when done with performing lifecycle changes
    /// Pass true in closure to mark the item as able to be completed and false to indicate it could not be completed
    typealias LifecycleDelegate = (CloudSyncProgressView, ((Bool) -> Void)?) -> Void
    
    enum Lifecycle {
        case show, hide, present(UserFacingError, UIButton)
    }
    
    private enum State {
        case idle, syncing, error, unavailable
    }
    
    private let idleButton        = UIButton(type: .system)
    private let syncingButton     = UIButton(type: .system)
    private let errorButton       = UIButton(type: .system)
    private let unavailableButton = UIButton(type: .system)
    private var progressToken: Any?
    private var timer: Timer?
    
    private let _progress: Any?
    @available(iOS 13.0, *)
    private var progress: AnyContinousProgress<GenericInitializationError, CloudKitSyncError>? {
        return _progress as? AnyContinousProgress<GenericInitializationError, CloudKitSyncError>
    }
    
    private var state: State = .idle {
        didSet {
            let view: UIView
            switch self.state {
            case .idle:
                view = self.idleButton
            case .syncing:
                view = self.syncingButton
            case .error:
                view = self.errorButton
            case .unavailable:
                view = self.unavailableButton
            }
            self.bringArrangedSubviewToFront(view)
        }
    }
    
    var lifecycleDelegate: LifecycleDelegate? {
        didSet {
            guard self.lifecycleDelegate != nil else { return }
            DispatchQueue.main.async { self.activateTimer() }
        }
    }
    private(set) var lifecycle: Lifecycle = .show {
        didSet {
            self.lifecycleDelegate?(self, { [weak self] _ in self?.activateTimer() })
        }
    }
    
    init(controller: BasicController?) {
        
        defer {
            self.animationDelegate = self
            self.addArrangedSubview(self.idleButton)
            self.addArrangedSubview(self.syncingButton)
            self.addArrangedSubview(self.errorButton)
            self.addArrangedSubview(self.unavailableButton)
            self.idleButton.alpha = 0
            self.syncingButton.alpha = 0
            self.errorButton.alpha = 0
            self.unavailableButton.alpha = 0
            // TODO: Put light gray somewhere in style
            self.idleButton.tintColor = .lightGray
            self.syncingButton.tintColor = .lightGray
            self.idleButton.isUserInteractionEnabled = false
            self.syncingButton.isUserInteractionEnabled = false
            // TODO: Add target action for ErrorButton, UnavailableButton
            self.errorButton.addTarget(self, action: #selector(self.showNextError(_:)), for: .touchUpInside)
            self.unavailableButton.addTarget(self, action: #selector(self.showUnavailableError(_:)), for: .touchUpInside)
        }
        
        guard #available(iOS 14.0, *) else {
            self._progress = nil
            super.init(frame: .zero)
            return
        }
        
        self._progress = controller?.syncProgress
        super.init(frame: .zero)
        self.progressToken = controller?.syncProgress?.objectWillChange.sink { [weak self] in
            self?.activateTimer()
        }
    }
    
    private func updateLabels() {
        
        let property: WritableKeyPath<UIEdgeInsets, CGFloat>
            = self.traitCollection.layoutDirection == .rightToLeft
            ? \.right
            : \.left
        // TODO: Put this -8 somewhere in style
        self.idleButton.imageEdgeInsets[keyPath: property] = -8
        self.syncingButton.imageEdgeInsets[keyPath: property] = -8
        self.errorButton.imageEdgeInsets[keyPath: property] = -8
        self.unavailableButton.imageEdgeInsets[keyPath: property] = -8
        
        if #available(iOS 13.0, *) {
            self.idleButton.setImage(UIImage(systemName: "checkmark.icloud"), for: .normal)
            self.syncingButton.setImage(UIImage(systemName: "arrow.clockwise.icloud"), for: .normal)
            self.errorButton.setImage(UIImage(systemName: "exclamationmark.icloud"), for: .normal)
            self.unavailableButton.setImage(UIImage(systemName: "xmark.icloud"), for: .normal)
        }
        // TODO: Localize Strings
        // TODO: Create mew font for this use case
        // IdleButton and SyncingButton need black fonts
        // ErrorButton and UnavailableButton need tint color fonts
        self.idleButton.setAttributedTitle(
            NSAttributedString(string: "iCloud Sync Complete",
                               font: .migratorSecondaryButton),
            for: .normal
        )
        self.syncingButton.setAttributedTitle(
            NSAttributedString(string: "Syncing with iCloud…",
                               font: .migratorSecondaryButton),
            for: .normal
        )
        self.errorButton.setAttributedTitle(
            NSAttributedString(string: "Sync Error",
                               font: .migratorSecondaryButton),
            for: .normal
        )
        self.unavailableButton.setAttributedTitle(
            NSAttributedString(string: "iCloud Sync Unavailable on this Device",
                               font: .migratorSecondaryButton),
            for: .normal
        )
    }
    
    private func activateTimer() {
        let invalidate = {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        guard #available(iOS 14.0, *), let progress = self.progress else {
            invalidate()
            self.state = .unavailable
            self.lifecycle = .show
            return
        }
        
        guard self.timer == nil else { return }
        defer { self.timer?.fire() }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            let error: UserFacingError? = progress.initializeError ?? progress.errorQ.first
            guard error == nil else {
                invalidate()
                self?.state = .error
                self?.lifecycle = .show
                return
            }
            if progress.progress.fractionCompleted < 1 {
                self?.state = .syncing
                self?.lifecycle = .show
            } else {
                let oldState = self?.state
                self?.state = .idle
                if oldState == .idle {
                    // if the state was previously idle, then we want to let
                    // the timer invalidate and for the hide lifecycle to be fired.
                    // This makes it so the user sees the sync was completed
                    // 2 seconds before disappearing
                    invalidate()
                    self?.lifecycle = .hide
                }
            }
        }
    }
    
    @objc private func showNextError(_ sender: UIButton) {
        guard
            #available(iOS 14.0, *),
            let error: UserFacingError = self.progress?.initializeError
                                      ?? self.progress?.errorQ.popFirst()
        else { return }
        self.lifecycle = .present(error, sender)
    }
    
    @objc private func showUnavailableError(_ sender: UIButton) {
        self.lifecycle = .present(Error.notAvailable, sender)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLabels()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard self.window != nil else { return }
        self.updateLabels()
        let oldState = self.state
        self.state = oldState
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CloudSyncProgressView: ZStackViewAnimationDelegate {
    func didReorderArrangedSubviews(_ stackView: ZStackView) {
        UIView.style_animateNormal({
            stackView.arrangedSubviews.enumerated().forEach { index, view in
                if index == 0 {
                    view.alpha = 1
                    view.transform = .identity
                } else {
                    view.alpha = 0
                    view.transform = CGAffineTransform(translationX: -100, y: 0)
                }
            }
        }, completion: { _ in
            stackView.arrangedSubviews.first?.isUserInteractionEnabled = true
            stackView.arrangedSubviews.dropFirst().forEach { view in
                view.isUserInteractionEnabled = false
                view.transform = CGAffineTransform(translationX: +100, y: 0)
            }
        })
    }
}

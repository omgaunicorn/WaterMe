//
//  CloudSyncProgressView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2021/05/04.
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
import Calculate
import Datum

class CloudSyncProgressView: UIStackView {
    
    enum Lifecycle {
        case show, hide, present(UserFacingError)
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
    private var progress: AnyContinousProgress? {
        return _progress as? AnyContinousProgress
    }
    
    private var state: State = .idle {
        didSet {
            self.idleButton.isHidden        = self.state != .idle
            self.syncingButton.isHidden     = self.state != .syncing
            self.errorButton.isHidden       = self.state != .error
            self.unavailableButton.isHidden = self.state != .unavailable
        }
    }
    
    var lifecycleDelegate: ((Lifecycle, CloudSyncProgressView) -> Void)? {
        didSet {
            guard self.lifecycleDelegate != nil else { return }
            DispatchQueue.main.async { self.activateTimer() }
        }
    }
    private var lifecycle: Lifecycle = .show {
        didSet {
            self.lifecycleDelegate?(self.lifecycle, self)
        }
    }
    
    init(controller: BasicController?) {
        
        defer {
            self.axis = .horizontal
            self.addArrangedSubview(self.idleButton)
            self.addArrangedSubview(self.syncingButton)
            self.addArrangedSubview(self.errorButton)
            self.addArrangedSubview(self.unavailableButton)
            // TODO: Put light gray somewhere in style
            // self.idleButton.tintColor = .lightGray
            // self.syncingButton.tintColor = .lightGray
            self.idleButton.isUserInteractionEnabled = false
            self.syncingButton.isUserInteractionEnabled = false
            // TODO: Put this -8 somewhere in style
            self.idleButton.imageEdgeInsets.left = -8
            self.syncingButton.imageEdgeInsets.left = -8
            self.errorButton.imageEdgeInsets.left = -8
            self.unavailableButton.imageEdgeInsets.left = -8
            // TODO: Add target action for ErrorButton, UnavailableButton
            self.errorButton.addTarget(self, action: #selector(self.showNextError(_:)), for: .touchUpInside)
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
    
    // TODO: Make private again
    func activateTimer() {
        guard #available(iOS 14.0, *), let progress = self.progress else {
            self.timer?.invalidate()
            self.timer = nil
            self.state = .unavailable
            return
        }
        guard self.timer == nil else { return }
        defer { self.timer?.fire() }
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            let invalidate = {
                self?.timer?.invalidate()
                self?.timer = nil
            }
            let error = progress.initializeError ?? progress.errorQ.first
            guard error == nil else {
                self?.state = .error
                invalidate()
                self?.lifecycle = .show
                return
            }
            if progress.progress.fractionCompleted < 1 {
                self?.state = .syncing
                self?.lifecycle = .show
            } else {
                self?.state = .idle
                invalidate()
                self?.lifecycle = .hide
            }
        }
    }
    
    @objc private func showNextError(_ sender: UIButton?) {
        guard
            #available(iOS 13.0, *),
              let error = self.progress?.initializeError
                       ?? self.progress?.errorQ.popFirst()
        else { return }
        self.lifecycle = .present(error)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLabels()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.updateLabels()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

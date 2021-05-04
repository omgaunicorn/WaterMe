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
    
    private enum State {
        case idle, syncing, error
    }
    
    private let idleIcon: UIImageView = .init()
    private let idleLabel: UILabel = .init()
    private let syncingIcon: UIImageView = .init()
    private let syncingLabel: UILabel = .init()
    private let errorIcon: UIImageView = .init()
    private let errorButton: UIButton = .init(type: .system)
    
    private let _progress: Any?
    private var progressToken: Any?
    private var timer: Timer?
    @available(iOS 13.0, *)
    private var progress: AnyContinousProgress? {
        return _progress as? AnyContinousProgress
    }
    
    private var state: State = .idle {
        didSet {
            UIView.style_animateNormal {
                self.idleIcon.isHidden = true
                self.idleLabel.isHidden = true
                self.syncingIcon.isHidden = true
                self.syncingLabel.isHidden = true
                self.errorIcon.isHidden = true
                self.errorButton.isHidden = true
                switch self.state {
                case .idle:
                    self.idleIcon.isHidden = false
                    self.idleLabel.isHidden = false
                case .syncing:
                    self.syncingIcon.isHidden = false
                    self.syncingLabel.isHidden = false
                case .error:
                    self.errorIcon.isHidden = false
                    self.errorButton.isHidden = false
                }
            }
        }
    }
    
    init(controller: BasicController?) {
        
        defer {
            self.updateLabels()
            self.axis = .horizontal
            self.addArrangedSubview(self.idleIcon)
            self.addArrangedSubview(self.idleLabel)
            self.addArrangedSubview(self.syncingIcon)
            self.addArrangedSubview(self.syncingLabel)
            self.addArrangedSubview(self.errorIcon)
            self.addArrangedSubview(self.errorButton)
            self.idleIcon.contentMode = .scaleAspectFit
            self.syncingIcon.contentMode = .scaleAspectFit
            self.errorIcon.contentMode = .scaleAspectFit
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
        self.activateTimer()
    }
    
    private func updateLabels() {
        if #available(iOS 13.0, *) {
            self.idleIcon.image = UIImage(systemName: "checkmark.icloud")
            self.syncingIcon.image = UIImage(systemName: "arrow.clockwise.icloud")
            self.errorIcon.image = UIImage(systemName: "exclamationmark.icloud")
        }
        self.idleLabel.attributedText = NSAttributedString(
            string: "iCloud Sync Complete",
            font: Font.migratorBody
        )
        self.syncingLabel.attributedText = NSAttributedString(
            string: "Syncing with iCloud",
            font: Font.migratorBody
        )
        self.errorButton.setAttributedTitle(
            NSAttributedString(string: "Sync Error", font: .migratorBody),
            for: .normal
        )
        self.spacing = UIStackView.spacingUseSystem
    }
    
    private func activateTimer() {
        guard #available(iOS 14.0, *) else {
            self.timer?.invalidate()
            self.timer = nil
            // TODO: set state to unsupported
            return
        }
        guard self.timer == nil else { return }
        defer { self.timer?.fire() }
        self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            let progress = self?.progress
            let error = progress?.initializeError ?? progress?.errorQ.first
            guard error == nil else {
                self?.state = .error
                self?.timer?.invalidate()
                self?.timer = nil
                return
            }
            let completed = progress?.progress.fractionCompleted ?? 1
            switch completed {
            case ..<1:
                self?.state = .syncing
            case 1...:
                self?.state = .idle
                self?.timer?.invalidate()
                self?.timer = nil
            default:
                break
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateLabels()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

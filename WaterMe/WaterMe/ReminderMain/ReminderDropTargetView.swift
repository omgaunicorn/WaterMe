//
//  ReminderDropTargetView.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 20/12/17.
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

import AVFoundation
import UIKit

class ReminderDropTargetView: UIView {

    enum VideoState: Int {
        case noHover, hover, drop
    }

    private let kVideoStartTime = CMTime(value: 1, timescale: 100)
    private let kVideoHoverTime = CMTime(value: 170, timescale: 100)
    private let kVideoEndTime = CMTime(value: 533, timescale: 100)
    private let kRate = Float(1.0)
    private let kVideoLandscapeAsset = AVPlayerItem(url: Bundle(for: ReminderDropTargetView.self).url(forResource: "iPhone5-landscape", withExtension: "mov", subdirectory: "Videos")!)
    private let kVideoPortraitAsset = AVPlayerItem(url: Bundle(for: ReminderDropTargetView.self).url(forResource: "iPhone5-portrait", withExtension: "mov", subdirectory: "Videos")!)

    private let videoLayer: AVPlayerLayer = {
        let l = AVPlayerLayer()
        l.videoGravity = .resizeAspect
        return l
    }()

    private let player: AVQueuePlayer = {
        let p = AVQueuePlayer()
        p.allowsExternalPlayback = false
        p.actionAtItemEnd = .pause
        return p
    }()

    var videoState = VideoState.noHover {
        didSet {
            switch self.videoState {
            case .noHover:
                if self.videoLayer.opacity < 1 {
                    self.player.pause()
                    self.player.seek(to: kVideoStartTime)
                    self.videoLayer.opacity = 1
                } else {
                    self.player.playImmediately(atRate: -1 * kRate)
                }
            case .hover:
                if self.videoLayer.opacity < 1 {
                    self.player.pause()
                    self.player.seek(to: kVideoStartTime)
                    self.videoLayer.opacity = 1
                    self.player.playImmediately(atRate: kRate)
                } else {
                    if self.player.currentTime().seconds > kVideoHoverTime.seconds {
                        self.player.playImmediately(atRate: -1 * kRate)
                    } else {
                        self.player.playImmediately(atRate: kRate)
                    }
                }
            case .drop:
                self.player.playImmediately(atRate: kRate)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let token1 = self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: kVideoHoverTime)], queue: nil) { [unowned self] in
            guard case .hover = self.videoState else { return }
            self.player.pause()
        }

        let token2 = self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: kVideoEndTime)], queue: nil) { [unowned self] in
            self.videoLayer.opacity = 0
        }

        self.observerTokens += [token1, token2]
        self.videoLayer.player = self.player
        self.layer.addSublayer(self.videoLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer.frame = self.layer.bounds
    }

    // TODO: Fix CMTime and observers so things work in landscape
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.player.removeAllItems()
        super.traitCollectionDidChange(previousTraitCollection)
        switch self.traitCollection.verticalSizeClass {
        case .regular, .unspecified:
            self.player.insert(kVideoLandscapeAsset, after: nil)
        case .compact:
            self.player.insert(kVideoPortraitAsset, after: nil)
        }
    }

    private var observerTokens = [Any]()

    deinit {
        for token in self.observerTokens {
            self.player.removeTimeObserver(token)
        }
    }

}

//
//  WateringVideoManager.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 22/12/17.
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

class DragAndDropPlayerManager {

    enum HoverState: Int {
        case noHover, hover, drop
    }

    private let kVideoStartTime = CMTime(value: 1, timescale: 100)
    private let kVideoHoverTime = CMTime(value: 165, timescale: 100)
    private let kVideoEndTime = CMTime(value: 533, timescale: 100)
    private let kRate = Float(1.0)
    // TODO: Fix CMTime and observers so things work in landscape
    private let kVideoLandscapeAsset = AVPlayerItem(url: Bundle(for: ReminderDropTargetView.self).url(forResource: "iPhone5-landscape", withExtension: "mov", subdirectory: "Videos")!)
    private let kVideoPortraitAsset = AVPlayerItem(url: Bundle(for: ReminderDropTargetView.self).url(forResource: "iPhone5-portrait", withExtension: "mov", subdirectory: "Videos")!)

    private(set) var videoLayerShouldBeHidden = true {
        didSet {
            self.videoHiddenChanged?(self.videoLayerShouldBeHidden)
        }
    }

    let player: AVQueuePlayer = {
        let p = AVQueuePlayer()
        p.allowsExternalPlayback = false
        p.actionAtItemEnd = .pause
        return p
    }()

    var landscapeVideo = true {
        didSet {
            self.player.removeAllItems()
            switch self.landscapeVideo {
            case true:
                self.player.insert(kVideoLandscapeAsset, after: nil)
            case false:
                self.player.insert(kVideoPortraitAsset, after: nil)
            }
        }
    }

    var videoHiddenChanged: ((Bool) -> Void)?

    var hoverState = HoverState.noHover {
        didSet {
            switch self.hoverState {
            case .noHover:
                if self.videoLayerShouldBeHidden == true {
                    self.player.pause()
                    self.player.seek(to: kVideoStartTime)
                    self.videoLayerShouldBeHidden = false
                } else {
                    self.player.playImmediately(atRate: -1 * kRate)
                }
            case .hover:
                if self.videoLayerShouldBeHidden == true {
                    self.player.pause()
                    self.player.seek(to: kVideoStartTime)
                    self.videoLayerShouldBeHidden = false
                    self.player.playImmediately(atRate: kRate)
                } else {
                    if self.player.currentTime().seconds > kVideoHoverTime.seconds {
                        self.player.playImmediately(atRate: -1 * kRate)
                    } else {
                        self.player.playImmediately(atRate: kRate)
                    }
                }
            case .drop:
                if self.videoLayerShouldBeHidden == true {
                    self.player.pause()
                    self.player.seek(to: kVideoStartTime)
                    self.videoLayerShouldBeHidden = false
                    self.player.playImmediately(atRate: kRate)
                } else {
                    self.player.playImmediately(atRate: kRate)
                }
            }
        }
    }

    init() {
        let token1 = self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: kVideoStartTime)], queue: nil) { [unowned self] in
            guard case .noHover = self.hoverState else { return }
            self.videoLayerShouldBeHidden = true
        }

        let token2 = self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: kVideoHoverTime)], queue: nil) { [unowned self] in
            guard case .hover = self.hoverState else { return }
            self.player.pause()
        }

        let token3 = self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: kVideoEndTime)], queue: nil) { [unowned self] in
            self.videoLayerShouldBeHidden = true
        }

        self.observerTokens += [token1, token2, token3]
    }

    private var observerTokens = [Any]()

    private func removeAllTokens() {
        for token in self.observerTokens {
            self.player.removeTimeObserver(token)
        }
    }

    deinit {
        self.removeAllTokens()
    }
}

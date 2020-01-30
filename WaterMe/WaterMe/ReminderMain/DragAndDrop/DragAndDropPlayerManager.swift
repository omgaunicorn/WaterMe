//
//  DragAndDropPlayerManager.swift
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

    enum HoverState {
        case noHover, hover, drop
    }

    struct Configuration {
        var landscapeTimings: Timings
        var portraitTimings: Timings
        var forwardRate: Float
        var reverseRate: Float
        var landscapeVideoURL: URL
        var portraitVideoURL: URL
    }

    struct Timings {
        var start: CMTime
        var hover: CMTime
        var end: CMTime
    }

    private var startTime: CMTime {
        switch self.landscapeVideo {
        case true:
            return configuration.landscapeTimings.start
        case false:
            return configuration.portraitTimings.start
        }
    }
    private var hoverTime: CMTime {
        switch self.landscapeVideo {
        case true:
            return configuration.landscapeTimings.hover
        case false:
            return configuration.portraitTimings.hover
        }
    }
    private var endTime: CMTime {
        switch self.landscapeVideo {
        case true:
            return configuration.landscapeTimings.end
        case false:
            return configuration.portraitTimings.end
        }
    }

    private let configuration: Configuration
    private lazy var landscapeVideoAsset = AVPlayerItem.style_videoAsset(
        at: self.configuration.landscapeVideoURL,
        forDarkMode: false
    )
    private lazy var portraitVideoAsset = AVPlayerItem.style_videoAsset(
        at: self.configuration.portraitVideoURL,
        forDarkMode: false
    )
    private lazy var darkLandscapeVideoAsset = AVPlayerItem.style_videoAsset(
        at: self.configuration.landscapeVideoURL,
        forDarkMode: true
    )
    private lazy var darkPortraitVideoAsset = AVPlayerItem.style_videoAsset(
        at: self.configuration.portraitVideoURL,
        forDarkMode: true
    )

    private(set) var videoLayerShouldBeHidden = true {
        didSet {
            self.videoHiddenChanged?(self.videoLayerShouldBeHidden)
        }
    }

    let player: AVQueuePlayer = {
        let p = AVQueuePlayer()
        p.allowsExternalPlayback = false
        p.actionAtItemEnd = .pause
        p.volume = 0
        return p
    }()

    private var landscapeVideo = true

    var videoHiddenChanged: ((Bool) -> Void)?

    var hoverState = HoverState.noHover {
        didSet {
            switch self.hoverState {
            case .noHover:
                if self.videoLayerShouldBeHidden == true {
                    self.player.pause()
                    self.player.seek(to: startTime)
                } else {
                    self.player.playImmediately(atRate: self.configuration.reverseRate)
                }
            case .hover:
                if self.videoLayerShouldBeHidden == true {
                    self.player.pause()
                    self.player.seek(to: startTime)
                    self.videoLayerShouldBeHidden = false
                    self.player.playImmediately(atRate: self.configuration.forwardRate)
                } else {
                    if self.player.currentTime().seconds > hoverTime.seconds {
                        self.player.playImmediately(atRate: self.configuration.reverseRate)
                    } else {
                        self.player.playImmediately(atRate: self.configuration.forwardRate)
                    }
                }
            case .drop:
                if self.videoLayerShouldBeHidden == true {
                    self.player.pause()
                    self.player.seek(to: startTime)
                    self.videoLayerShouldBeHidden = false
                }
                self.player.playImmediately(atRate: self.configuration.forwardRate)
            }
        }
    }

    init(configuration: Configuration) {
        self.configuration = configuration
        let token = self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 60),
                                                        queue: nil)
        { [unowned self] currentTime in
            switch self.player.rate {
            case 0...: // Forward
                switch self.hoverState {
                case .drop:
                    let testTime = self.landscapeVideo ?
                        configuration.landscapeTimings.end :
                        configuration.portraitTimings.end
                    guard currentTime >= testTime else { return }
                    self.videoLayerShouldBeHidden = true
                    self.hoverState = .noHover
                case .hover, .noHover:
                    let testTime = self.landscapeVideo ?
                        configuration.landscapeTimings.hover :
                        configuration.portraitTimings.hover
                    guard currentTime >= testTime else { return }
                    self.player.pause()
                }
            case ...0: // Backward
                let testTime = self.landscapeVideo ?
                    configuration.landscapeTimings.start :
                    configuration.portraitTimings.start
                guard currentTime <= testTime else { return }
                self.videoLayerShouldBeHidden = true
                self.hoverState = .noHover
            default:
                break
            }
        }
        self.observerToken = token
    }

    func updateVideoAssets(landscape: Bool, darkMode: Bool) {
        self.player.removeAllItems()
        self.landscapeVideo = landscape
        switch (landscape, darkMode) {
        case (true, false):
            self.player.insert(self.landscapeVideoAsset, after: nil)
        case (false, false):
            self.player.insert(self.portraitVideoAsset, after: nil)
        case (true, true):
            self.player.insert(self.darkLandscapeVideoAsset, after: nil)
        case (false, true):
            self.player.insert(self.darkPortraitVideoAsset, after: nil)
        }
    }

    func hardReset() {
        self.hoverState = .noHover
        self.videoLayerShouldBeHidden = true
        self.player.pause()
        self.player.seek(to: startTime)
    }

    private var observerToken: Any?

    deinit {
        if let token = self.observerToken {
            self.player.removeTimeObserver(token)
        }
    }
}

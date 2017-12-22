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

    private let videoLayer: AVPlayerLayer = {
        let l = AVPlayerLayer()
        l.videoGravity = .resizeAspect
        return l
    }()

    private let player: AVQueuePlayer = {
        let p = AVQueuePlayer(items: [ReminderDropTargetView.videoAsset])
        p.allowsExternalPlayback = false
        p.actionAtItemEnd = .pause
        return p
    }()

    private let kVideoStartTime = CMTime(value: 1, timescale: 100)
    private let kVideoHoverTime = CMTime(value: 70, timescale: 100)
    private let kVideoEndTime = CMTime(value: 533, timescale: 100)
    private let kRate = Float(1.0)

    private static let videoAsset = AVPlayerItem(url: Bundle(for: ReminderDropTargetView.self).url(forResource: "iPhone5-landscape", withExtension: "mov", subdirectory: "Videos")!)

    enum VideoState: Int {
        case noHover, hover, drop
    }

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

        let time1 = kVideoStartTime
        self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: time1)], queue: nil) { [unowned self] in
            print("START")
        }

        let time2 = kVideoHoverTime
        self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: time2)], queue: nil) { [unowned self] in
            print("MIDDLE")
            guard case .hover = self.videoState else { return }
            self.player.pause()
        }

        let time3 = kVideoEndTime
        self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: time3)], queue: nil) { [unowned self] in
            print("END")
            self.videoLayer.opacity = 0
        }

        self.videoLayer.player = self.player
        self.layer.addSublayer(self.videoLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer.frame = self.layer.bounds
    }

}

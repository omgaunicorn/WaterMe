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

    private static let videoStart = CMTime(value: 1, timescale: 100)
    private static let videoHoverStop = CMTime(value: 70, timescale: 100)
    private static let videoEnd = CMTime(value: 533, timescale: 100)

    private static let videoAsset = AVPlayerItem(url: Bundle(for: ReminderDropTargetView.self).url(forResource: "iPhone5-landscape", withExtension: "mov", subdirectory: "Videos")!)

    override func awakeFromNib() {
        super.awakeFromNib()

        let time1 = type(of: self).videoStart
        self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: time1)], queue: nil) { [unowned self] in
            print("START")
            if self.player.rate < 0 {
                self.player.rate = 1
            }
        }

        let time2 = type(of: self).videoHoverStop
        self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: time2)], queue: nil) { [unowned self] in
            print("MIDDLE")
        }

        let time3 = type(of: self).videoEnd
        self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: time3)], queue: nil) { [unowned self] in
            print("END")
            if self.player.rate > 0 {
                self.player.rate = -1
            }
        }

        self.videoLayer.player = self.player
        self.layer.addSublayer(self.videoLayer)
    }

    func play() {
        self.player.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer.frame = self.layer.bounds
    }

}

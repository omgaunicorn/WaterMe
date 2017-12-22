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

    var hoverState: DragAndDropPlayerManager.HoverState {
        set { self.videoManager.hoverState = newValue }
        get { return self.videoManager.hoverState }
    }

    private let videoManager = DragAndDropPlayerManager()

    private let videoLayer: AVPlayerLayer = {
        let l = AVPlayerLayer()
        l.videoGravity = .resizeAspect
        l.opacity = 0
        return l
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.videoManager.videoHiddenChanged = { [unowned self] hidden in
            self.videoLayer.opacity = hidden ? 0 : 1
        }
        self.videoLayer.player = self.videoManager.player
        self.layer.addSublayer(self.videoLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer.frame = self.layer.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        switch self.traitCollection.verticalSizeClass {
        case .regular, .unspecified:
            self.videoManager.landscapeVideo = true
        case .compact:
            self.videoManager.landscapeVideo = false
        }
    }
}

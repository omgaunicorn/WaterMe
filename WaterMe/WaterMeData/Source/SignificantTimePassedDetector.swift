//
//  SignificantTimePassedDetector.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 7/2/18.
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

import Foundation

public protocol SignificantTimePassedDetectorDelegate: class {
    func significantTimePassed(with reason: SignificantTimePassedDetector.Reason)
}

public class SignificantTimePassedDetector {

    public enum Reason {
        case STCNotification, BackupDetector
    }

    public weak var delegate: SignificantTimePassedDetectorDelegate?
    private var lastTimeChangeEventDate = Date()

    public init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.significantTimeChanged(_:)),
                                               name: .UIApplicationSignificantTimeChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didBecomeActive(_:)),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
    }

    @objc private func significantTimeChanged(_ notification: Any) {
        self.fire(with: .STCNotification)
    }

    @objc private func didBecomeActive(_ notification: Any) {
        // this is a backup detection. Hopefully, iOS will always send the STC notiication when needed
        // but every time the app is foregrounded, we need to check if the data needs to be reloaded
        // with analytics, I'll be able to see if this backup test is ever needed
        // if its not, I'll remove it.

        // wait before doing anything. So SignificantTimeChangeNotification has a chance to fire
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            timer.invalidate()
            self.checkAndFireIfNeeded()
        }
    }

    private func checkAndFireIfNeeded() {
        let isInToday = Calendar.current.isDateInToday(self.lastTimeChangeEventDate)
        if isInToday == false {
            self.fire(with: .BackupDetector)
        }
    }

    private func fire(with reason: SignificantTimePassedDetector.Reason) {
        self.lastTimeChangeEventDate = Date()
        self.delegate?.significantTimePassed(with: reason)
    }
}

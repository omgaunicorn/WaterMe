//
//  DispatchQueue+WaterMe.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 10/4/18.
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

extension DispatchQueue {

    // TODO: Terrible Hack
    // What does this code allow to happen???
    // Maybe it can be removed
    private static let mainQueueKey = DispatchSpecificKey<()>()

    public static func configureMainQueue() {
        self.main.setSpecific(key: self.mainQueueKey, value: ())
    }

    public static var isMain: Bool {
        return self.getSpecific(key: self.mainQueueKey) != nil
    }

    public var isMain: Bool {
        return self.getSpecific(key: DispatchQueue.mainQueueKey) != nil
    }
}

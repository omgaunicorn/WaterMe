//
//  ReminderWrapper.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/15.
//  Copyright © 2020 Saturday Apps.
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

import RealmSwift

public enum ReminderConstants {
    public static let minimumInterval: Int = 1
    public static let maximumInterval: Int = 180
    public static let defaultInterval: Int = 7
}

public protocol ReminderWrapper: ModelCompleteCheckable {
    var kind: ReminderKind { get }
    var uuid: String { get }
    var interval: Int { get }
    var note: String? { get }
    var nextPerformDate: Date? { get }
    var isModelComplete: ModelCompleteError? { get }
    var vessel: ReminderVesselWrapper? { get }
    var performed: ReminderPerformCollection { get }
    func observe(_ block: @escaping (ReminderChange) -> Void) -> ObservationToken
}

public protocol ReminderPerformCollection {
    var count: Int { get }
    subscript(index: Int) -> ReminderPerformWrapper { get }
    var last: ReminderPerformWrapper? { get }
}

public protocol ReminderPerformWrapper {
    var date: Date { get }
}

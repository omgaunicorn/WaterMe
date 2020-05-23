//
//  ReminderCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/09.
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

public protocol ReminderCollection {
    var count: Int { get }
    var isInvalidated: Bool { get }
    subscript(index: Int) -> Reminder { get }
    func compactMap<E>(_ transform: (Reminder) throws -> E?) rethrows -> [E]
    func index(matching predicateFormat: String, _ args: Any...) -> Int?
}

public protocol ReminderQuery {
    func observe(_: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken
}

public enum ReminderChange {
    case error(Error)
    case change
    case deleted
}

public typealias ReminderCollectionChange = CollectionChange<ReminderCollection, Int>
public typealias Update<U> = (insertions: [U], deletions: [U], modifications: [U])

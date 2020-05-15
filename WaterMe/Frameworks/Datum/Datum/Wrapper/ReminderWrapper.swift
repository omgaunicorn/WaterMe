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

public struct ReminderWrapper {
    
    internal var wrappedObject: Reminder
    
    internal init(_ reminder: Reminder) {
        self.wrappedObject = reminder
    }
    
    public var kind: Reminder.Kind { self.wrappedObject.kind }
    public var uuid: String { self.wrappedObject.uuid }
    public var interval: Int { self.wrappedObject.interval }
    public var note: String? { self.wrappedObject.note }
    public var nextPerformDate: Date? { self.wrappedObject.nextPerformDate }
    public var vessel: ReminderVessel? { self.wrappedObject.vessel }
    public var performed: LazyMapSequence<List<ReminderPerform>, ReminderPerform> { self.wrappedObject.performed.lazy.map({ $0 }) }
    public var isModelComplete: ModelCompleteError? { self.wrappedObject.isModelComplete }
    
}

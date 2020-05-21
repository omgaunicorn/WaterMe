//
//  CD_GroupedReminderCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/20.
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

internal class CD_GroupedReminderCollectionImp: GroupedReminderCollection {

    var changeObserver: ((GroupedReminderCollectionChange) -> Void)?

    var numberOfSections: Int {
        return 0
    }

    subscript(indexPath: IndexPath) -> Reminder? {
        return nil
    }

    func numberOfItems(inSection section: Int) -> Int {
        return 0
    }

    internal func indexPathOfReminder(with identifier: ReminderIdentifier) -> IndexPath? {
        return nil
    }
}

//
//  RLM_GroupedReminderCollection.swift
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

internal class RLM_GroupedReminderCollectionImp: GroupedReminderCollection {

    private let basicController: RLM_BasicController
    private var reminderGedeg: ReminderGedeg?

    init(basicController: RLM_BasicController) {
        self.basicController = basicController
    }

    var changeObserver: ((GroupedReminderCollectionChange) -> Void)? {
        didSet {
            if let newValue = self.changeObserver {
                self.reminderGedeg = ReminderGedeg(basicRC: self.basicController, observer: newValue)
            } else {
                self.reminderGedeg = nil
            }
        }
    }

    var numberOfSections: Int {
        return self.reminderGedeg?.numberOfSections ?? 0
    }

    subscript(indexPath: IndexPath) -> Reminder? {
        return self.reminderGedeg?.reminder(at: indexPath)
    }

    func numberOfItems(inSection section: Int) -> Int {
        return self.reminderGedeg?.numberOfItems(inSection: section) ?? 0
    }

    internal func indexPathOfReminder(with identifier: Identifier) -> IndexPath? {
        return self.reminderGedeg?.indexPathOfReminder(with: identifier)
    }
}

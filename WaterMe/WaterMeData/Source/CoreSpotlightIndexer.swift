//
//  CoreSpotlightIndexer.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 10/2/18.
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

import RealmSwift
import CoreSpotlight

public class CoreSpotlightIndexer: HasBasicController {

    private let queue: RunLoopEnabledQueue = {
        let name = "com.saturdayapps.waterme.csindexer.queue.\(UUID().uuidString)"
        let q = RunLoopEnabledQueue(name: name, priority: .background)
        return q
    }()

    private var reminders: AnyRealmCollection<Reminder>?
    private var reminderVessels: AnyRealmCollection<ReminderVessel>?

    public var basicRC: BasicController? {
        didSet { self.hardReloadData() }
    }

    private var remindersToken: NotificationToken?
    private var reminderVesselsToken: NotificationToken?

    public init() { }

    private func hardReloadData() {
        self.queue.execute(async: false) {
            self.remindersToken?.invalidate()
            self.remindersToken = nil
            self.reminderVesselsToken?.invalidate()
            self.reminderVesselsToken = nil
            guard let basicRC = self.basicRC else { return }
            self.reminders = basicRC.allReminders().value
            self.reminderVessels = basicRC.allVessels().value
            self.remindersToken = self.reminders?.observe() { [weak self] c in
                self?.remindersChanged(c)
            }
            self.reminderVesselsToken = self.reminderVessels?.observe() { [weak self] c in
                self?.reminderVesselsChanged(c)
            }
        }
    }

    private func remindersChanged(_ changes: RealmCollectionChange<AnyRealmCollection<Reminder>>) {
        assert(Thread.isMainThread == false && Thread.current === self.queue.thread)
        print("REMINDERS CHANGED")
    }

    private func reminderVesselsChanged(_ changes: RealmCollectionChange<AnyRealmCollection<ReminderVessel>>) {
        assert(Thread.isMainThread == false && Thread.current === self.queue.thread)
        print("REMINDER VESSELS CHANGED")
        switch changes {
        case .initial(let data):
            break
        case .update(let data, let dels, let ins, let mods):
            break
        case .error(let error):
            log.error(error)
            assertionFailure(String(describing: error))
        }
    }
}

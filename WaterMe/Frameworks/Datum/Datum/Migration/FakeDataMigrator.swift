//
//  FakeDataMigrator.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/08/03.
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

#if DEBUG

import Calculate

class FakeDataMigrator: Migratable {

    let realMigrator: RealmToCoreDataMigrator

    init() throws {
        let source = try RLM_BasicController(kind: .local, forTesting: true)
        self.realMigrator = RealmToCoreDataMigrator(testingSource: source)!

        let vesselCount = 50
        let reminderCount = 30
        let performCount = 10
        "Creating Fake Vessels: \(vesselCount)".log(as: .debug)
        let emojiChoice = ["💐", "🌷", "🌹", "🥀", "🌻", "🌼", "🌸", "🌺", "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈", "🍒", "🍑", "🍍", "🥝", "🥑", "🍅", "🍆", "🥒", "🥕", "🌽", "🌶", "🥔", "🍠", "🌰", "🥜", "🌵", "🎄", "🌲", "🌳", "🌴", "🌱", "🌿", "☘️", "🍀", "🎍", "🎋", "🍃", "🍂", "🍁", "🍄", "🌾", "🥚", "🍳", "🐔", "🐧", "🐤", "🐣", "🐥", "🐓", "🦆", "🦃", "🐇", "🦀", "🦑", "🐙", "🦐", "🍤", "🐠", "🐟", "🐢", "🐍", "🦎", "🐝", "🍯", "🥐", "🍞", "🥖", "🧀", "🥗", "🍣", "🍱", "🍛", "🍚", "☕️", "🍵", "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯", "🦁", "🐮", "🥛", "🐷", "🐽", "🐸", "🐒", "🦅", "🦉", "🦇", "🐺", "🐗", "🐴", "🦄", "🐛", "🦋", "🐌", "🐚", "🐞", "🐜", "🕷", "🦂", "🐡", "🐬", "🦈", "🐳", "🐋", "🐊", "🐆", "🐅", "🐃", "🐂", "🐄", "🦌", "🐪", "🐫", "🐘", "🦏", "🦍", "🐎", "🐖", "🐐", "🐏", "🐑", "🐕", "🐩", "🐈", "🕊", "🐁", "🐀", "🐿", "🐉", "🐲"]
        for vIDX in 1...vesselCount {
            try autoreleasepool {
                let v = try source.newReminderVessel(displayName: "v_\(vIDX)", icon: .emoji(emojiChoice.randomElement()!)).get()
                let rs: [RLM_Reminder] = try (1...reminderCount).map { rIDX in
                    let r = try source.newReminder(for: v).get()
                    try source.update(kind: nil, interval: nil, note: "v_\(vIDX)_r_\(rIDX)", in: r).get()
                    return (r as! RLM_ReminderWrapper).wrappedObject
                }
                for _ in 1...performCount {
                    try autoreleasepool {
                        try source.appendNewPerform(to: rs).get()
                    }
                }
            }
        }
        "Created Fake Vessels: \(vesselCount)".log(as: .debug)
    }

    func start(destination: BasicController, completion: @escaping (MigratableResult) -> Void) -> Progress {
        return self.realMigrator.start(destination: destination, completion: completion)
    }

    func skipMigration() -> MigratableResult {
        return self.realMigrator.skipMigration()
    }
}

#endif

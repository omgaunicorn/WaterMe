//
//  BasicController.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/17.
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

import UIKit

public protocol HasBasicController {
    var basicRC: BasicController? { get set }
}

extension HasBasicController {
    public mutating func configure(with basicRC: BasicController?) {
        guard let basicRC = basicRC else { return }
        self.basicRC = basicRC
    }
}

public enum ControllerKind {
    case local, sync
}

public protocol BasicController: class {

    var remindersDeleted: (([ReminderValue]) -> Void)? { get set }
    var reminderVesselsDeleted: (([ReminderVesselValue]) -> Void)? { get set }
    var userDidPerformReminder: (() -> Void)? { get set }

    var kind: ControllerKind { get }

    // MARK: Create
    func newReminder(for vessel: ReminderVesselWrapper) -> Result<ReminderWrapper, DatumError>
    func newReminderVessel(displayName: String?, icon: ReminderVesselIcon?, reminders: [ReminderWrapper]?) -> Result<ReminderVesselWrapper, DatumError>

    // MARK: Read
    func allVessels() -> Result<ReminderVesselQuery, DatumError>
    func allReminders(sorted: ReminderSortOrder, ascending: Bool) -> Result<ReminderQuery, DatumError>
    func reminders(in section: ReminderSection, sorted: ReminderSortOrder, ascending: Bool) -> Result<ReminderQuery, DatumError>
    func reminderVessel(matching identifier: ReminderVesselIdentifier) -> Result<ReminderVesselWrapper, DatumError>
    func reminder(matching identifier: ReminderIdentifier) -> Result<ReminderWrapper, DatumError>

    // MARK: Update
    func update(displayName: String?, icon: ReminderVesselIcon?, in vessel: ReminderVesselWrapper) -> Result<Void, DatumError>
    func update(kind: ReminderKind?, interval: Int?, note: String?, in reminder: ReminderWrapper) -> Result<Void, DatumError>
    func appendNewPerformToReminders(with identifiers: [ReminderIdentifier]) -> Result<Void, DatumError>

    // MARK: Delete
    func delete(vessel: ReminderVesselWrapper) -> Result<Void, DatumError>
    func delete(reminder: ReminderWrapper) -> Result<Void, DatumError>

    // MARK: Random
    func coreDataMigration(vesselName: String?, vesselImage: UIImage?, vesselEmoji: String?, reminderInterval: NSNumber?, reminderLastPerformDate: Date?) -> Result<Void, DatumError>
}

public func NewBasicController(of kind: ControllerKind) -> Result<BasicController, DatumError> {
    do {
        let bc = try RLM_BasicController(kind: kind)
        return .success(bc)
    } catch {
        return .failure(.createError)
    }
}

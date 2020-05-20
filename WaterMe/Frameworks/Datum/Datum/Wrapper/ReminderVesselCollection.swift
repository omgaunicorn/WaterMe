//
//  ReminderVesselCollection.swift
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

public class ReminderVesselCollection {
    private let collection: AnyRealmCollection<RLM_ReminderVessel>
    private let transform: (RLM_ReminderVessel) -> ReminderVesselWrapper = { RLM_ReminderVesselWrapper($0) }
    internal init(_ collection: AnyRealmCollection<RLM_ReminderVessel>) {
        self.collection = collection
    }
    
    public var count: Int { self.collection.count }
    public subscript(index: Int) -> ReminderVesselWrapper { self.transform(self.collection[index]) }
}

public protocol ReminderVesselQuery {
    func observe(_: @escaping (ReminderVesselCollectionChange) -> Void) -> ObservationToken
}

internal class ReminderVesselQueryImp: ReminderVesselQuery {
    private let collection: AnyRealmCollection<RLM_ReminderVessel>
    init(_ collection: AnyRealmCollection<RLM_ReminderVessel>) {
        self.collection = collection
    }
    func observe(_ block: @escaping (ReminderVesselCollectionChange) -> Void) -> ObservationToken {
        return self.collection.observe { realmChange in
            switch realmChange {
            case .initial(let data):
                block(.initial(data: .init(data)))
            case .update(_, let deletions, let insertions, let modifications):
                block(.update(insertions: insertions, deletions: deletions, modifications: modifications))
            case .error:
                block(.error(error: .readError))
            }
        }
    }
}

public enum ReminderVesselChange {
    case error(Error)
    case change(changedDisplayName: Bool, changedIconEmoji: Bool, changedReminders: Bool, changedPointlessBloop: Bool)
    case deleted
}

public typealias ReminderVesselCollectionChange = CollectionChange<ReminderVesselCollection, Int>

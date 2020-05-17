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
    private let transform: (RLM_ReminderVessel) -> ReminderVesselWrapper = { .init($0) }
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
            case .error(let error):
                block(.error(error: error))
            }
        }
    }
}

public enum ReminderVesselChange {
    case error(Error)
    case change(changedDisplayName: Bool, changedIconEmoji: Bool, changedReminders: Bool, changedPointlessBloop: Bool)
    case deleted
}

public enum ReminderVesselCollectionChange {
    case initial(data: ReminderVesselCollection)
    case update(insertions: [Int], deletions: [Int], modifications: [Int])
    case error(error: Error)
}

public protocol ReminderVesselObservable {
    func datum_observe(_ block: @escaping (ReminderVesselChange) -> Void) -> ObservationToken
    func datum_observeReminders(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken
}

extension ReminderVesselWrapper: ReminderVesselObservable {
    public func datum_observe(_ block: @escaping (ReminderVesselChange) -> Void) -> ObservationToken {
        return self.wrappedObject.observe { realmChange in
            switch realmChange {
            case .error(let error):
                block(.error(error))
            case .change(let properties):
                let changedDisplayName = RLM_ReminderVessel.propertyChangesContainDisplayName(properties)
                let changedIconEmoji = RLM_ReminderVessel.propertyChangesContainIconEmoji(properties)
                let changedReminders = RLM_ReminderVessel.propertyChangesContainReminders(properties)
                let changedPointlessBloop = RLM_ReminderVessel.propertyChangesContainPointlessBloop(properties)
                block(.change(changedDisplayName: changedDisplayName,
                              changedIconEmoji: changedIconEmoji,
                              changedReminders: changedReminders,
                              changedPointlessBloop: changedPointlessBloop))
            case .deleted:
                block(.deleted)
            }
        }
    }
    
    public func datum_observeReminders(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        return self.wrappedObject.reminders.observe { realmChange in
            switch realmChange {
            case .initial(let data):
                block(.initial(data: .init(AnyRealmCollection(data))))
            case .update(_, let deletions, let insertions, let modifications):
                block(.update(insertions: insertions, deletions: deletions, modifications: modifications))
            case .error(let error):
                block(.error(error: error))
            }
        }
    }
}

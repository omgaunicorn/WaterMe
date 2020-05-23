//
//  RLM_ReminderCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/21.
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

internal class RLM_ReminderCollection: ReminderCollection {
    private let collection: AnyRealmCollection<RLM_Reminder>
    private let transform: (RLM_Reminder) -> Reminder = { RLM_ReminderWrapper($0) }
    internal init(_ collection: AnyRealmCollection<RLM_Reminder>) {
        self.collection = collection
    }
    
    var count: Int { self.collection.count }
    var isInvalidated: Bool { self.collection.isInvalidated }
    subscript(index: Int) -> Reminder { self.transform(self.collection[index]) }
    func compactMap<E>(_ transform: (Reminder) throws -> E?) rethrows -> [E] {
        return try self.collection.compactMap { try transform(self.transform($0)) }
    }
    func index(matching predicateFormat: String, _ args: Any...) -> Int? {
        return self.collection.index(matching: predicateFormat, args)
    }
}

internal class RLM_ReminderQuery: ReminderQuery {
    private let collection: AnyRealmCollection<RLM_Reminder>
    init(_ collection: AnyRealmCollection<RLM_Reminder>) {
        self.collection = collection
    }
    func observe(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
        return self.collection.observe { realmChange in
            switch realmChange {
            case .initial(let data):
                block(.initial(data: RLM_ReminderCollection(data)))
            case .update(_, let deletions, let insertions, let modifications):
                block(.update((insertions: insertions, deletions: deletions, modifications: modifications)))
            case .error:
                block(.error(error: .readError))
            }
        }
    }
}

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

public class ReminderCollection {
    private let collection: AnyRealmCollection<Reminder>
    private let transform: (Reminder) -> ReminderWrapper = { .init($0) }
    internal init(_ collection: AnyRealmCollection<Reminder>) {
        self.collection = collection
    }
    
    public var count: Int { self.collection.count }
    public var isInvalidated: Bool { self.collection.isInvalidated }
    public subscript(index: Int) -> ReminderWrapper { self.transform(self.collection[index]) }
    public func compactMap<E>(_ transform: (ReminderWrapper) throws -> E?) rethrows -> [E] {
        return try self.collection.compactMap { try transform(self.transform($0)) }
    }
    public func index(matching predicateFormat: String, _ args: Any...) -> Int? {
        return self.collection.index(matching: predicateFormat, args)
    }
}

public protocol ReminderQuery {
    func observe(_: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken
}

internal class ReminderQueryImp: ReminderQuery {
    private let collection: AnyRealmCollection<Reminder>
    init(_ collection: AnyRealmCollection<Reminder>) {
        self.collection = collection
    }
    func observe(_ block: @escaping (ReminderCollectionChange) -> Void) -> ObservationToken {
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

public enum ReminderChange {
    case error(Error)
    case change
    case deleted
}

public enum ReminderCollectionChange {
    case initial(data: ReminderCollection)
    case update(insertions: [Int], deletions: [Int], modifications: [Int])
    case error(error: Error)
}

public protocol ReminderObservable {
    func datum_observe(_ block: @escaping (ReminderChange) -> Void) -> ObservationToken
}

extension ReminderWrapper: ReminderObservable {
    public func datum_observe(_ block: @escaping (ReminderChange) -> Void) -> ObservationToken {
        return self.wrappedObject.observe { realmChange in
            switch realmChange {
            case .error(let error):
                block(.error(error))
            case .change:
                block(.change)
            case .deleted:
                block(.deleted)
            }
        }
    }
}

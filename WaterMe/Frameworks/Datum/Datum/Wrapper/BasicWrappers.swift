//
//  BasicWrappers.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/10.
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
import CoreData

public enum CollectionChange<T, U> {
    case initial(data: T)
    case update(Update<U>)
    case error(error: DatumError)
}

public typealias Update<U> = (insertions: [U], deletions: [U], modifications: [U])

public protocol ObservationToken: class {
    func invalidate()
}

extension NotificationToken: ObservationToken {}
extension NSKeyValueObservation: ObservationToken {}

internal enum Token {
    static func wrap(_ block: () -> NSObjectProtocol) -> NCTokenWrapper {
        return .init(tokens: [block()])
    }
    static func wrap(_ block: () -> ObservationToken) -> TokenWrapper {
        return .init(tokens: [block()])
    }
    static func wrap(_ block: () -> [ObservationToken]) -> TokenWrapper {
        return .init(tokens: block())
    }
}

internal class NCTokenWrapper: ObservationToken {
    private var tokens: [NSObjectProtocol]
    init(tokens: [NSObjectProtocol]) {
        self.tokens = tokens
    }
    func invalidate() {
        let nv = NotificationCenter.default
        self.tokens.forEach { nv.removeObserver($0) }
    }
}

internal class TokenWrapper: ObservationToken {
    private var tokens: [ObservationToken]
    init(tokens: [ObservationToken]) {
        self.tokens = tokens
    }
    func invalidate() {
        self.tokens.forEach { $0.invalidate() }
        self.tokens = []
    }
}

internal class UpdatingFetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {
    private var changeInFlight: Update<IndexPath>!
    private let block: (Update<IndexPath>) -> Void
    internal init(_ block: @escaping (Update<IndexPath>) -> Void) {
        self.block = block
        super.init()
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.changeInFlight = (insertions: [], deletions: [], modifications: [])
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at index: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath newIndex: IndexPath?)
    {
        switch type {
        case .insert:
            self.changeInFlight.insertions.append(newIndex!)
        case .move:
            self.changeInFlight.deletions.append(index!)
            self.changeInFlight.insertions.append(newIndex!)
        case .update:
            self.changeInFlight.modifications.append(newIndex!)
        case .delete:
            self.changeInFlight.deletions.append(index!)
        @unknown default:
            break
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let changeInFlight = self.changeInFlight!
        self.changeInFlight = nil
        self.block(changeInFlight)
    }
}

internal let Transform_Update_IntToIndex: (Update<Int>, Int) -> Update<IndexPath> = { update, section in
    return (update.insertions.map { IndexPath(row: $0, section: section) },
            update.deletions.map { IndexPath(row: $0, section: section) },
            update.modifications.map { IndexPath(row: $0, section: section) })
}

internal let Transform_Update_IndexToInt: (Update<IndexPath>) -> Update<Int> = {
    return ($0.insertions.map { $0.row }, $0.deletions.map { $0.row }, $0.modifications.map { $0.row })
}

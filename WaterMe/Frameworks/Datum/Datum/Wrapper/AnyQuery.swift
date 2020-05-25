//
//  AnyQuery.swift
//  Datum
//
//  Created by jbergier on 2020/05/25.
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

public protocol CollectionQuery {
    associatedtype Index
    associatedtype Collection: Datum.Collection
    func observe(_: @escaping (CollectionChange<Collection, Index>) -> Void) -> ObservationToken
}

public struct AnyCollectionQuery<Collection: Datum.Collection, Index>: CollectionQuery {

    private let _observe: (@escaping (CollectionChange<Collection, Index>) -> Void) -> ObservationToken
    
    internal init<T: CollectionQuery>(_ query: T) where T.Collection == Collection, T.Index == Index, T.Collection.Index == Index {
        _observe = query.observe
    }
    
    public func observe(_ closure: @escaping (CollectionChange<Collection, Index>) -> Void) -> ObservationToken {
        return _observe(closure)
    }
}

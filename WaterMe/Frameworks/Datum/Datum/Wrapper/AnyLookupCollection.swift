//
//  AnyLookupCollection.swift
//  Datum
//
//  Created by Jeffrey Bergier on 2020/05/26.
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

public struct Identifier: Hashable, Codable {
    public var uuid: String
    public init(rawValue: String) {
        self.uuid = rawValue
    }
}

public protocol LookupCollection: BaseCollection {
    func index(of item: Element) -> Index?
    func indexOfItem(with identifier: Identifier) -> Index?
}

public struct AnyLookupCollection<Element, Index>: LookupCollection {

    private let _count: () -> Int
    private let _subscript: (Index) -> Element
    private let _index1: (Element) -> Index?
    private let _index2: (Identifier) -> Index?
    
    internal init<T: LookupCollection>(_ collection: T) where T.Element == Element, T.Index == Index {
        _subscript = { collection[$0] }
        _count = { collection.count }
        _index1 = collection.index
        _index2 = collection.indexOfItem
    }
    
    public var count: Int {
        return _count()
    }
    
    public subscript(index: Index) -> Element {
        return _subscript(index)
    }
    
    public func index(of item: Element) -> Index? {
        return _index1(item)
    }
    
    public func indexOfItem(with identifier: Identifier) -> Index? {
        return _index2(identifier)
    }
}



//
//  SchemaMigrationTests.swift
//  DatumTests
//
//  Created by Jeffrey Bergier on 2021/05/03.
//  Copyright © 2021 Saturday Apps. All rights reserved.
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

@testable import Datum
import CoreData
import XCTest

fileprivate let TestDB1URL     = Bundle(for: NonSyncContainer.self)
                                       .url(forResource: "TestDB", withExtension: "sqlite")!
fileprivate let TestDB2URL     = Bundle(for: NonSyncContainer.self)
                                       .url(forResource: "TestDB", withExtension: "sqlite-wal")!
fileprivate let StoreParentURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                                    .appendingPathComponent(UUID().uuidString, isDirectory: true)
fileprivate let Store1URL      = StoreParentURL.appendingPathComponent("WaterMe.sqlite", isDirectory: false)
fileprivate let Store2URL      = StoreParentURL.appendingPathComponent("WaterMe.sqlite-wal", isDirectory: false)

fileprivate class NonSyncContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return StoreParentURL
    }
}

fileprivate class SyncContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return StoreParentURL
    }
}

class CoreDataSchemaMigrationTests: XCTestCase {
        
    override func setUpWithError() throws {
        try super.setUpWithError()
        let fm = FileManager.default
        try fm.createDirectory(at: StoreParentURL,
                               withIntermediateDirectories: true,
                               attributes: nil)
        try fm.copyItem(at: TestDB1URL, to: Store1URL)
        try fm.copyItem(at: TestDB2URL, to: Store2URL)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        let fm = FileManager.default
        try fm.removeItem(at: StoreParentURL)
    }
    
    func test_nonSync_initialize_simpleMigration() throws {
        _ = try CD_BasicController(kind: .__testing_withClass(NonSyncContainer.self))
    }
    
    func test_sync_initialize_simpleMigration() throws {
        _ = try CD_BasicController(kind: .__testing_withClass(SyncContainer.self))
    }
    
}

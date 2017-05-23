//
//  AdminRealmController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/19/17.
//  Copyright © 2017 Saturday Apps. All rights reserved.
//

import RealmSwift

enum Subscription: String {
    case basic, pro, suspicious
    static let kReceiptKey = "WaterMeReceipt.realm"
    static let kBasicKey = "WaterMeBasic.realm"
    static let kProKey = "WaterMePro.realm"
}

class RealmFile: Object {
    fileprivate(set) dynamic var uuid = ""
    fileprivate(set) dynamic var name = ""
    fileprivate(set) dynamic var size = 0
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

class RealmUser: Object {
    fileprivate(set) dynamic var uuid = ""
    fileprivate(set) dynamic var size = 0
    private dynamic var subscriptionString: String = Subscription.suspicious.rawValue
    fileprivate(set) var subscription: Subscription {
        get {
            return Subscription(rawValue: self.subscriptionString) ?? .suspicious
        }
        set {
            self.subscriptionString = newValue.rawValue
        }
    }
    let files = List<RealmFile>()
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

class AdminRealmController {
    
    let config: Realm.Configuration = {
        var c = Realm.Configuration()
        c.schemaVersion = 3
        c.objectTypes = [RealmUser.self, RealmFile.self]
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        c.fileURL = url.appendingPathComponent("AdminConsole.realm", isDirectory: false)
        return c
    }()
    
    var realm: Realm {
        return try! Realm(configuration: self.config)
    }
    
    func allUsers() -> AnyRealmCollection<RealmUser> {
        let collection = self.realm.objects(RealmUser.self)
        return AnyRealmCollection(collection)
    }
    
    func deleteAll() {
        let realm = self.realm
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
    }
    
    func processServerDirectoryData(_ data: Data) throws {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        let dict = json as? NSDictionary
        let realmDataFiles = dict?["files"] as? NSArray
        let dir0 = realmDataFiles?.filter({ ($0 as! NSDictionary)["directoryName"] as! String == "0" }).first as! NSDictionary
        let dir0Files = dir0["files"] as? NSArray
        let userDir = dir0Files?.filter({ ($0 as? NSDictionary)?["directoryName"] as? String == "user_data" }).first as? NSDictionary
        let userFiles = (userDir?["files"] as? NSArray)?.filter({ ($0 as? NSDictionary)?["directoryName"] is String }) ?? []
        guard userFiles.isEmpty == false else { throw "No users found in data. There is probably a server issue." }
        for file in userFiles {
            guard
                let dict = file as? NSDictionary,
                let subFiles = dict["files"] as? NSArray,
                let userID = dict["directoryName"] as? String,
                userID.contains("_") == false && userID.contains(".") == false,
                subFiles.count > 0
            else { continue }
            let realmFiles = try subFiles.flatMap() { realmFile throws -> RealmFile? in
                guard
                    let realmFile = realmFile as? NSDictionary,
                    let name = realmFile["fileName"] as? String,
                    name.contains(".realm") == true && name.contains(".realm.lock") == false && name.contains("_") == false
                else { return nil }
                let size = realmFile["size"] as? Int ?? 0
                let liveObject = try self.newOrExistingRealmFile(withUUID: userID + "/" + name)
                try self.update(realmFile: liveObject, name: name, size: size)
                return liveObject
            }
            let liveRealmUser = try self.newOrExistingRealmUser(withUUID: userID)
            try self.update(realmUser: liveRealmUser, files: AnySequence(realmFiles))
        }
    }
    
    func newOrExistingRealmFile(withUUID uuid: String) throws -> RealmFile {
        let realm = self.realm
        if let existing = realm.object(ofType: RealmFile.self, forPrimaryKey: uuid) {
            return existing
        } else {
            let new = RealmFile()
            new.uuid = uuid
            realm.beginWrite()
            realm.add(new)
            try realm.commitWrite()
            return new
        }
    }
    
    func update(realmFile: RealmFile, name: String, size: Int) throws {
        let realm = self.realm
        realm.beginWrite()
        realmFile.name = name
        realmFile.size = size
        try realm.commitWrite()
    }
    
    func newOrExistingRealmUser(withUUID uuid: String) throws -> RealmUser {
        let realm = self.realm
        if let existing = realm.object(ofType: RealmUser.self, forPrimaryKey: uuid) {
            return existing
        } else {
            let new = RealmUser()
            new.uuid = uuid
            realm.beginWrite()
            realm.add(new)
            try realm.commitWrite()
            return new
        }
    }
    
    func update(realmUser: RealmUser, files: AnySequence<RealmFile>) throws {
        let realm = self.realm
        realm.beginWrite()
        realmUser.files.removeAll()
        realmUser.files.append(objectsIn: files)
        let totalSize = files.reduce(0, { $0.1.size + $0.0 })
        realmUser.size = totalSize
        let receiptPresent = realmUser.files.filter({ $0.name == Subscription.kReceiptKey }).isEmpty == false
        let basicPresent = realmUser.files.filter({ $0.name == Subscription.kBasicKey }).isEmpty == false
        let proPresent = realmUser.files.filter({ $0.name == Subscription.kProKey }).isEmpty == false
        let otherPresent = realmUser.files.filter({ $0.name != Subscription.kProKey && $0.name != Subscription.kBasicKey && $0.name != Subscription.kReceiptKey }).isEmpty == false
        if otherPresent == true {
            realmUser.subscription = Subscription.suspicious
        } else if basicPresent && receiptPresent && !proPresent {
            realmUser.subscription = Subscription.basic
        } else if basicPresent && receiptPresent && proPresent {
            realmUser.subscription = Subscription.pro
        } else {
            realmUser.subscription = Subscription.suspicious
        }
        try realm.commitWrite()
    }
}

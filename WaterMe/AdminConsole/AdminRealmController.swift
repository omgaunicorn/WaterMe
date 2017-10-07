//
//  AdminRealmController.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 5/19/17.
//  Copyright © 2017 Saturday Apps.
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



import WaterMeData
import RealmSwift

enum DataPresent: String {
    case basic, pro, suspicious, none
    static let kReceiptKey = "WaterMeReceipt.realm"
    static let kBasicKey = "WaterMeBasic.realm"
    static let kProKey = "WaterMePro.realm"
    var isSuspicious: Bool {
        switch self {
        case .basic, .pro:
            return false
        case .suspicious, .none:
            return true
        }
    }
    var localizedString: String {
        switch self {
        case .basic:
            return "WaterMe Basic"
        case .none:
            return "No Realms"
        case .pro:
            return "WaterMe Pro"
        case .suspicious:
            return "Suspicious Realms"
        }
    }
}

class ConsoleError: Object {
    @objc dynamic var date = Date()
    @objc dynamic var code = 0
    @objc dynamic var file = ""
    @objc dynamic var line = 0
    @objc dynamic var function = ""
}

class RealmFile: Object {
    @objc fileprivate(set) dynamic var uuid = ""
    @objc fileprivate(set) dynamic var name = ""
    @objc fileprivate(set) dynamic var size = 0
    let owners = LinkingObjects(fromType: RealmUser.self, property: "files")
    var owner: RealmUser? {
        return self.owners.first
    }
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

class RealmUser: Object {
    @objc fileprivate(set) dynamic var uuid = ""
    @objc fileprivate(set) dynamic var size = 0
    @objc private dynamic var _dataPresent: String = DataPresent.suspicious.rawValue
    fileprivate(set) var dataPresent: DataPresent {
        get {
            return DataPresent(rawValue: _dataPresent) ?? .suspicious
        }
        set {
            _dataPresent = newValue.rawValue
        }
    }
    @objc fileprivate(set) dynamic var isSizeSuspicious = false
    let files = List<RealmFile>()
    @objc fileprivate(set) dynamic var latestReceipt: Receipt?
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

class AdminRealmController {
    
    private let config: Realm.Configuration = {
        var c = Realm.Configuration()
        c.schemaVersion = 10
        c.objectTypes = [RealmUser.self, RealmFile.self, Receipt.self, ConsoleError.self]
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        c.fileURL = url.appendingPathComponent("AdminConsole.realm", isDirectory: false)
        return c
    }()
    
    private var realm: Realm {
        return try! Realm(configuration: self.config)
    }
    
    func allUsers() -> AnyRealmCollection<RealmUser> {
        let collection = self.realm.objects(RealmUser.self)
        return AnyRealmCollection(collection)
    }
    
    func allReceiptFiles() -> AnyRealmCollection<RealmFile> {
        let keyPath = #keyPath(RealmFile.name)
        let collection = self.realm.objects(RealmFile.self).filter("\(keyPath) = 'WaterMeReceipt.realm'")
        return AnyRealmCollection(collection)
    }
    
    func allErrors() -> AnyRealmCollection<ConsoleError> {
        let collection = self.realm.objects(ConsoleError.self).sorted(byKeyPath: #keyPath(ConsoleError.date))
        return AnyRealmCollection(collection)
    }
    
    func user(withUUID uuid: String) -> RealmUser? {
        let realm = self.realm
        let user = realm.object(ofType: RealmUser.self, forPrimaryKey: uuid)
        return user
    }
    
    func addError(with code: Int, file: String, function: String, line: Int) {
        let error = ConsoleError()
        error.code = code
        error.file = file
        error.function = function
        error.line = line
        let realm = self.realm
        realm.beginWrite()
        realm.add(error)
        try! realm.commitWrite()
    }
    
    func update(user: RealmUser, with receipt: Receipt) {
        let realm = self.realm
        realm.beginWrite()
        if let oldReceipt = user.latestReceipt {
            realm.delete(oldReceipt)
        }
        let newReceipt = receipt.__admin_console_only_realmFreeCopy()
        user.latestReceipt = newReceipt
        try! realm.commitWrite()
    }
    
    func update(realmFile: RealmFile, name: String, size: Int) {
        let realm = self.realm
        realm.beginWrite()
        realmFile.name = name
        realmFile.size = size
        try! realm.commitWrite()
    }
    
    func deleteAll() {
        let realm = self.realm
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
    }
    
    func processServerDirectoryData(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            let error = AdminRealmControllerError.jsonErrorDecodingFileList
            log.error(error)
            self.addError(with: error.rawValue, file: #file, function: #function, line: #line)
            return
        }
        let dict = json as? NSDictionary
        let realmDataFiles = dict?["files"] as? NSArray
        let dir0 = realmDataFiles?.filter({ ($0 as! NSDictionary)["directoryName"] as! String == "0" }).first as! NSDictionary
        let dir0Files = dir0["files"] as? NSArray
        let userDir = dir0Files?.filter({ ($0 as? NSDictionary)?["directoryName"] as? String == "user_data" }).first as? NSDictionary
        let userFiles = (userDir?["files"] as? NSArray)?.filter({ ($0 as? NSDictionary)?["directoryName"] is String }) ?? []
        guard userFiles.isEmpty == false else {
            let error = AdminRealmControllerError.noFilesFoundInFileListJSON
            log.error(error)
            self.addError(with: error.rawValue, file: #file, function: #function, line: #line)
            return
        }
        for file in userFiles {
            guard
                let dict = file as? NSDictionary,
                let subFiles = dict["files"] as? NSArray,
                let userID = dict["directoryName"] as? String,
                userID.contains("_") == false && userID.contains(".") == false,
                subFiles.count > 0
            else {
                let error = AdminRealmControllerError.invalidUserNameFoundInFileListJSON
                log.error(error)
                self.addError(with: error.rawValue, file: #file, function: #function, line: #line)
                continue
            }
            let realmFiles = subFiles.flatMap() { realmFile -> RealmFile? in
                guard
                    let realmFile = realmFile as? NSDictionary,
                    let name = realmFile["fileName"] as? String,
                    name.contains(".realm") == true && name.contains(".realm.lock") == false && name.contains("_") == false
                else {
                    let error = AdminRealmControllerError.invalidFileFoundInRealmFolderOfFileListJSON
                    log.error(error)
                    self.addError(with: error.rawValue, file: #file, function: #function, line: #line)
                    return nil
                }
                let size = realmFile["size"] as? Int ?? 0
                let liveObject = self.newOrExistingRealmFile(withUUID: userID + "/" + name)
                self.update(realmFile: liveObject, name: name, size: size)
                return liveObject
            }
            let liveRealmUser = self.newOrExistingRealmUser(withUUID: userID)
            self.update(realmUser: liveRealmUser, files: AnySequence(realmFiles))
        }
    }
    
    private func newOrExistingRealmFile(withUUID uuid: String) -> RealmFile {
        let realm = self.realm
        if let existing = realm.object(ofType: RealmFile.self, forPrimaryKey: uuid) {
            return existing
        } else {
            let new = RealmFile()
            new.uuid = uuid
            realm.beginWrite()
            realm.add(new)
            try! realm.commitWrite()
            return new
        }
    }
    
    private func newOrExistingRealmUser(withUUID uuid: String) -> RealmUser {
        let realm = self.realm
        if let existing = realm.object(ofType: RealmUser.self, forPrimaryKey: uuid) {
            return existing
        } else {
            let new = RealmUser()
            new.uuid = uuid
            realm.beginWrite()
            realm.add(new)
            try! realm.commitWrite()
            return new
        }
    }
    
    private func update(realmUser: RealmUser, files: AnySequence<RealmFile>) {
        let realm = self.realm
        realm.beginWrite()
        realmUser.files.removeAll()
        realmUser.files.append(objectsIn: files)
        // hack to trigger notifications again when pairing files with users
        realmUser.files.forEach() { file in
            let oldSize = file.size
            file.size = oldSize
        }
        let totalSize = files.reduce(0, { $1.size + $0 })
        realmUser.size = totalSize
        realmUser.isSizeSuspicious = totalSize >= 10000000 ? true : false
        let receiptPresent = realmUser.files.filter({ $0.name == DataPresent.kReceiptKey }).isEmpty == false
        let basicPresent = realmUser.files.filter({ $0.name == DataPresent.kBasicKey }).isEmpty == false
        let proPresent = realmUser.files.filter({ $0.name == DataPresent.kProKey }).isEmpty == false
        let otherPresent = realmUser.files.filter({ $0.name != DataPresent.kProKey && $0.name != DataPresent.kBasicKey && $0.name != DataPresent.kReceiptKey }).isEmpty == false
        if realmUser.files.isEmpty {
            realmUser.dataPresent = .none
        } else if otherPresent == true {
            realmUser.dataPresent = DataPresent.suspicious
        } else if basicPresent && receiptPresent && !proPresent {
            realmUser.dataPresent = DataPresent.basic
        } else if basicPresent && receiptPresent && proPresent {
            realmUser.dataPresent = DataPresent.pro
        } else {
            realmUser.dataPresent = DataPresent.suspicious
        }
        try! realm.commitWrite()
    }
}

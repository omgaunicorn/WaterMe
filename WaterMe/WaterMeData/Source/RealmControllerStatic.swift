//
//  RealmControllerStatic.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/16/17.
//
//

import CloudKit
import RealmSwift

public extension RealmController {
    
    public enum Kind {
        case local, basic(SyncUser), pro(SyncUser)
    }
    
    public class var localRealmExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.localRealmFile.path)
        return exists
    }
    
    public class var loggedInUser: SyncUser? {
        return SyncUser.current
    }
    
    internal class var localRealmDirectory: URL {
        let appsupport = FileManager.default.urls(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
        let url = appsupport.appendingPathComponent("WaterMe", isDirectory: true).appendingPathComponent("FreeEdition", isDirectory: true)
        return url
    }
    
    internal class var localRealmFile: URL {
        return self.localRealmDirectory.appendingPathComponent("Realm.realm", isDirectory: false)
    }
    
    internal class func createLocalRealmDirectoryIfNeeded() throws {
        if self.localRealmExists == false {
            try FileManager.default.createDirectory(at: RealmController.localRealmDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

public extension Realm.Configuration {
    
    init(kind: RealmController.Kind, userPath: String) {
        let schemaVersion: UInt64 = 1
        var fileURL: URL?
        var syncConfig: SyncConfiguration?
        switch kind {
        case .local:
            fileURL = RealmController.localRealmFile
        case .basic(let user):
            let url = user.realmURL(withAppName: "WaterMeBasic", userPath: userPath)
            syncConfig = SyncConfiguration(user: user, realmURL: url, enableSSLValidation: true)
        case .pro(let user):
            let url = user.realmURL(withAppName: "WaterMePro", userPath: userPath)
            syncConfig = SyncConfiguration(user: user, realmURL: url, enableSSLValidation: true)
        }
        self.init(fileURL: fileURL, syncConfiguration: syncConfig, schemaVersion: schemaVersion, objectTypes: [Receipt.self])
    }
}

public extension SyncUser {
    public static func cloudKitUser(with cloudKitID: CKRecordID, completionHandler: ((Result<SyncUser>) -> Void)?) {
        let server = PrivateKeys.kRealmServer
        let credential = SyncCredentials.cloudKit(token: cloudKitID.recordName)
        SyncUser.logIn(with: credential, server: server) { user, error in
            guard let user = user else { completionHandler?(.error(error!)); return; }
            completionHandler?(.success(user))
        }
    }
    fileprivate func realmURL(withAppName appName: String, userPath: String) -> URL {
        return self.authenticationServer!.realmURL(withAppName: appName, userPath: userPath)
    }
}

//@testable internal
internal extension URL {
    internal func realmURL(withAppName appName: String, userPath: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        if components.scheme == "https" {
            components.scheme = "realms"
        } else {
            components.scheme = "realm"
        }
        if components.path.characters.last == "/" {
            components.path += userPath + appName
        } else {
            components.path += "/" + userPath + appName
        }
        let url = components.url!
        return url
    }
}

public extension CKContainer {
    public func token(completionHandler: ((Result<CKRecordID>) -> Void)?) {
        self.fetchUserRecordID { id, error in
            if let id = id {
                completionHandler?(.success(id))
            } else {
                completionHandler?(.error(error!))
            }
        }
    }
}

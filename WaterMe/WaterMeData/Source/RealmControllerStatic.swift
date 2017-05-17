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
        case local, synced(SyncUser)
    }
    
    public class var localRealmExists: Bool {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: self.localRealmFile.path)
        return exists
    }
    
    public class var loggedInUser: SyncUser? {
        return SyncUser.current
    }
    
    public class func loginWithCloudKit(completionHandler: ((Result<RealmController>) -> Void)?) {
        let container = CKContainer.default()
        container.fetchUserRecordID { id, error in
            guard let id = id else {
                completionHandler?(.error(error!))
                return
            }
            let server = PrivateKeys.kRealmServer
            let credential = SyncCredentials.cloudKit(token: id.recordName)
            SyncUser.logIn(with: credential, server: server) { user, error in
                guard let user = user else {
                    completionHandler?(.error(error!))
                    return
                }
                let rc = RealmController(kind: .synced(user))
                completionHandler?(.success(rc))
            }
        }
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

internal extension RealmController.Kind {
    internal var configuration: Realm.Configuration {
        let url: URL
        switch self {
        case .local:
            url = RealmController.localRealmFile
        case .synced(let user):
            url = user.realmURL(withAppName: "WaterMeBasic")
        }
        let config = type(of: self).config(from: self, realmURL: url)
        return config
    }
    
    private static func config(from kind: RealmController.Kind, realmURL: URL) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.schemaVersion = 1
        switch kind {
        case .local:
            config.fileURL = realmURL
        case .synced(let user):
            config.syncConfiguration = SyncConfiguration(user: user, realmURL: realmURL, enableSSLValidation: true)
        }
        return config
    }
}

fileprivate extension SyncUser {
    fileprivate func realmURL(withAppName appName: String) -> URL {
        return self.authenticationServer!.realmURL(withAppName: appName)
    }
}

//@testable internal
internal extension URL {
    internal func realmURL(withAppName appName: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        if components.scheme == "https" {
            components.scheme = "realms"
        } else {
            components.scheme = "realm"
        }
        if components.path.characters.last == "/" {
            components.path += "~/" + appName
        } else {
            components.path += "/~/" + appName
        }
        let url = components.url!
        return url
    }
}

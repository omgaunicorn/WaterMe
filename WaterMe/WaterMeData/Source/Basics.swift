//
//  Basics.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/15/17.
//
//

import RealmSwift
import XCGLogger
import CloudKit

internal let RealmSchemaVersion: UInt64 = 1

internal let log = XCGLogger.default

public enum Result<T> {
    case error(Error), success(T)
}

internal extension URL {
    internal func realmURL(withAppName appName: String, userPath: String) -> URL {
        var userPath = userPath
        if userPath.characters.first == "/" {
            userPath.remove(at: userPath.startIndex)
        }
        if userPath.characters.last != "/" {
            userPath += "/"
        }
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

public extension SyncUser {
    public static func cloudKitUser(with cloudKitID: CKRecordID, completionHandler: ((Result<SyncUser>) -> Void)?) {
        let server = PrivateKeys.kRealmServer
        let credential = SyncCredentials.cloudKit(token: cloudKitID.recordName)
        SyncUser.logIn(with: credential, server: server) { user, error in
            guard let user = user else { completionHandler?(.error(error!)); return; }
            completionHandler?(.success(user))
        }
    }
    internal func realmURL(withAppName appName: String, userPath: String? = nil) -> URL {
        let userPath = userPath ?? "~/"
        return self.authenticationServer!.realmURL(withAppName: appName, userPath: userPath)
    }
}

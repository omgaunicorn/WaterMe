//
//  Basics.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/15/17.
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

import Result
import RealmSwift
import XCGLogger
import CloudKit

internal let log = XCGLogger.default

internal extension URL {
    internal func realmURL(withAppName appName: String, userPath: String) -> URL {
        var userPath = userPath
        if userPath.first == "/" {
            userPath.remove(at: userPath.startIndex)
        }
        if userPath.last != "/" {
            userPath += "/"
        }
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        if components.scheme == "https" {
            components.scheme = "realms"
        } else {
            components.scheme = "realm"
        }
        if components.path.last == "/" {
            components.path += userPath + appName
        } else {
            components.path += "/" + userPath + appName
        }
        let url = components.url!
        return url
    }
}

public extension CKContainer {
    public func token(completionHandler: ((Result<CKRecordID, AnyError>) -> Void)?) {
        self.fetchUserRecordID { id, error in
            if let id = id {
                completionHandler?(.success(id))
            } else {
                completionHandler?(.failure(AnyError(error!)))
            }
        }
    }
}

public extension SyncUser {
    public static func cloudKitUser(with cloudKitID: CKRecordID, completionHandler: ((Result<SyncUser, AnyError>) -> Void)?) {
        let server = PrivateKeys.kRealmServer
        let credential = SyncCredentials.cloudKit(token: cloudKitID.recordName)
        SyncUser.logIn(with: credential, server: server) { user, error in
            guard let user = user else { completionHandler?(.failure(AnyError(error!))); return; }
            completionHandler?(.success(user))
        }
    }
    internal func realmURL(withAppName appName: String, userPath: String? = nil) -> URL {
        let userPath = userPath ?? "~/"
        return self.authenticationServer!.realmURL(withAppName: appName, userPath: userPath)
    }
}

public extension String {
    public var leadingTrailingWhiteSpaceTrimmedNonEmptyString: String? {
        let stripped = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard stripped.isEmpty == false else { return nil }
        return stripped
    }
}

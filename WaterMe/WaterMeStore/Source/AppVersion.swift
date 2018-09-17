//
//  AppVersion.swift
//  WaterMeStore
//
//  Created by Jeffrey Bergier on 9/16/18.
//  Copyright © 2018 Saturday Apps.
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

import Foundation

public struct AppVersion: Equatable {
    var major: Int
    var minor: Int
    var bug: Int
    init?(versionString: String) {
        let rawArray = versionString.components(separatedBy: ".")
        guard rawArray.count == 3 else { return nil }
        let uintArray = rawArray.compactMap({ UInt($0) })
        let intArray = uintArray.compactMap({ Int($0) })
        guard intArray.count == 3 else { return nil }
        self.major = intArray[0]
        self.minor = intArray[1]
        self.bug = intArray[2]
    }
}

extension AppVersion: Comparable {
    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if rhs.major > lhs.major {
            return true
        }
        let majorGreaterOrEqual = rhs.major >= lhs.major
        if majorGreaterOrEqual && rhs.major > lhs.major {
            return true
        }
        let minorGreaterOrEqual = rhs.minor >= lhs.minor
        if majorGreaterOrEqual && minorGreaterOrEqual && rhs.bug > lhs.bug {
            return true
        }
        return false
    }
}

public extension AppVersion {
    public static func fetchFromBundle(_ bundle: Bundle = .main) -> AppVersion? {
        guard let versionString = bundle.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return AppVersion(versionString: versionString)
    }
}

public extension AppVersion {
    public static func fetchFromAppStore(_ completion: @escaping (AppVersion?) -> Void) {
        // TODO: This is for dev only - take it out ASAP
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            completion(AppVersion(versionString: "2.1.0")!)
        }
        return
        guard let url = PrivateKeys.kAppInfoJSONURL else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    log.error("Request Failed with Error: \(error)")
                    completion(nil)
                    return
                }
                let response = response as? HTTPURLResponse
                guard response?.successfulStatusCode == true else {
                    log.error("Invalid Response: \(response?.statusCode ?? -1)")
                    completion(nil)
                    return
                }
                guard
                    let data = data,
                    let _json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let json = _json as? NSDictionary,
                    let versionArray = json.value(forKeyPath: "results.version") as? NSArray,
                    let versionString = versionArray.firstObject as? String,
                    let version = AppVersion(versionString: versionString)
                else {
                    log.error("Invalid Data")
                    completion(nil)
                    return
                }
                completion(version)
            }
        }
        task.resume()
    }
}

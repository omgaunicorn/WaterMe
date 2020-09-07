//
//  LogConfigurator.swift
//  Calculate
//
//  Created by Jeffrey Bergier on 2020/08/10.
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

import XCGLogger
import CryptoKit
import ServerlessLogger

public private(set) var log: XCGLogger!

public func LogConfigure(with delegate: ServerlessLoggerErrorDelegate?) {
    let identifier = "WaterMe-Lambda-Logger"
    var _log: XCGLogger!
    if #available(iOS 13.0, *) {
        let endpoint = URLComponents(url: PrivateKeys.kLoggerEndpoint, resolvingAgainstBaseURL: false)!
        let key = SymmetricKey(data: PrivateKeys.kLoggerKey)
        var config = Logger.DefaultSecureConfiguration(identifier: identifier,
                                                       endpointURL: endpoint,
                                                       hmacKey: key,
                                                       logLevel: .warning,
                                                       errorDelegate: delegate)
        config.storageLocation.appName = "WaterMe"
        _log = try? Logger(configuration: config)
    }
    _log = _log ?? XCGLogger(identifier: identifier, includeDefaultDestinations: true)
    #if DEBUG
    _log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .debug)
    #else
    _log.setup(level: .warning, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .warning)
    #endif
    log = _log
}

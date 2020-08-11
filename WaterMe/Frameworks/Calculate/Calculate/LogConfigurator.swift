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

public let log: XCGLogger = {
    let log = ErrorPreservingLogger(identifier: "WaterMe-Lambda-Logger", includeDefaultDestinations: true)
    #if DEBUG
    log.setup(level: .debug, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .debug)
    #else
    log.setup(level: .warning, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: true, showFileNames: false, showLineNumbers: false, showDate: true, writeToFile: false, fileLevel: .warning)
    #endif
    log.add(destination: LambdaCommsLogDestination())
    return log
}()

internal class LambdaCommsLogDestination: DestinationProtocol {
    var identifier: String = "WaterMe-Lambda-LogMonitor"
    var debugDescription: String { return self.identifier }
    var outputLevel: XCGLogger.Level = .error
    var haveLoggedAppDetails: Bool = true
    var owner: XCGLogger?
    var formatters: [LogFormatterProtocol]?
    var filters: [FilterProtocol]?

    func process(logDetails: LogDetails) {
        let event = Lambda.Event(details: logDetails)
        dump(event)
    }

    func processInternal(logDetails: LogDetails) { }

    func isEnabledFor(level: XCGLogger.Level) -> Bool {
        switch level {
        case .verbose:
            return false
        case .debug:
            return false
        case .info:
            return false
        case .notice:
            return false
        case .warning:
            return false
        case .error:
            return true
        case .severe:
            return true
        case .alert:
            return true
        case .emergency:
            return true
        case .none:
            return false
        }
    }
}

internal class ErrorPreservingLogger: XCGLogger {
    static let kErrorKey = "JSBLoggerError"
    override func logln(_ level: Level = .debug,
                        functionName: String = #function,
                        fileName: String = #file,
                        lineNumber: Int = #line,
                        userInfo: [String: Any] = [:],
                        closure: () -> Any?)
    {
        var userInfo = userInfo
        if let closureResult = closure() as? NSError {
            userInfo[ErrorPreservingLogger.kErrorKey] = closureResult
        }
        super.logln(level,
                    functionName: functionName,
                    fileName: fileName,
                    lineNumber: lineNumber,
                    userInfo: userInfo,
                    closure: closure)
    }
}

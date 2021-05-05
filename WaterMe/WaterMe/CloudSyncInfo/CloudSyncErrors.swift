//
//  CloudSyncErrors.swift
//  WaterMe
//
//  Created by Jeffrey Bergier on 2021/05/05.
//  Copyright © 2021 Saturday Apps.
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

import Calculate

extension GenericSyncError: UserFacingError {
    public static var errorDomain: String { "com.saturdayapps.waterme.GenericSyncError" }
    public var isCritical: Bool { false }
    public var recoveryActions: [RecoveryAction] { [] }
    public var title: String? { "iCloud Sync Error" }
    public var message: String? {
        switch self {
        case .unknown(let error):
            return error.localizedDescription
        }
    }
    public var errorCode: Int {
        switch self {
        case .unknown(let error):
            return (error as NSError).code
        }
    }
}

extension GenericInitializationError: UserFacingError {
    // TODO: Localize this
    public var title: String? { "iCloud Sync Error" }
    public var message: String? {
        switch self {
        case .couldNotDetermine:
            return "Unable to detect your iCloud account status. Turning your device off and on may resolve this issue."
        case .restricted:
            return "iCloud Sync is restricted by parental or administrator controls."
        case .noAccount:
            return "You are not signed into iCloud on this device. To use iCloud Sync with WaterMe, please sign into an iCloud account. If you do not want to see this error, disable 'Sync via iCloud' using the button below."
        }
    }
    public var recoveryActions: [RecoveryAction] { [.openWaterMeSettings] }
    public var isCritical: Bool { false }
    public static var errorDomain: String { "com.saturdayapps.waterme.GenericInitializationError" }
    public var errorCode: Int {
        switch self {
        case .couldNotDetermine:
            return 1001
        case .restricted:
            return 1002
        case .noAccount:
            return 1003
        }
    }
}

extension CloudSyncProgressView {
    enum Error: UserFacingError {
        static var errorDomain: String { "com.saturdayapps.waterme.CloudSyncProgressView" }
        case notAvailable
        var errorCode: Int {
            switch self {
            case .notAvailable:
                return 1001
            }
        }
        var title: String? { "iCloud Sync Error" }
        var message: String? { "iCloud Sync is not available on this device. iCloud Sync in WaterMe is only available on devices running iOS 14 or newer. Also, verify that 'Sync via iCloud' is enabled in settings." }
        var recoveryActions: [RecoveryAction] { [.openWaterMeSettings] }
        var isCritical: Bool { false }
    }
}

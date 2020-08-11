//
//  LambdaComms.swift
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
import UIKit
import Foundation

internal enum Lambda {}
extension Lambda {
    struct Event: Codable {
        let incident: UInt32 = UInt32.random(in: 1000000000..<UInt32.max)
        let userId = UIDevice.current.identifierForVendor?.uuidString ?? "-1"
        let logDetails: _LogDetails
        let deviceDetails = DeviceDetails()
        let errorDetails: ErrorDetails?
        init(details: LogDetails) {
            self.logDetails = .init(details)
            self.errorDetails = (details.userInfo[ErrorPreservingLogger.kErrorKey] as? NSError).map { .init($0) }
        }
    }
}

extension Lambda.Event {

    struct _LogDetails: Codable {
        let level: XCGLogger.Level
        let date: Date
        let message: String
        let functionName: String
        let fileName: String
        let lineNumber: Int
        init(_ input: LogDetails) {
            // swiftlint:disable operator_usage_whitespace
            self.level        = input.level
            self.date         = input.date
            self.message      = input.message
            self.functionName = input.functionName
            self.fileName     = input.fileName
            self.lineNumber   = input.lineNumber
            // swiftlint:enable operator_usage_whitespace
        }
    }

    struct DeviceDetails: Codable {
        // swiftlint:disable operator_usage_whitespace
        let systemVersion    = UIDevice.current.systemVersion
        let systenName       = UIDevice.current.systemName
        let model            = UIDevice.current.model
        let localizedModel   = UIDevice.current.localizedModel
        let batteryLevel     = UIDevice.current.batteryLevel
        let batteryState     = UIDevice.current.batteryState.stringValue
        let storageRemaining = (LazyDiskCapacityCache?.volumeAvailableCapacity ?? -1000000) / 1000000
        let storageTotal     = (LazyDiskCapacityCache?.volumeTotalCapacity ?? -1000000) / 1000000
        let memoryFree:  Int
        let memoryUsed:  Int
        let memoryTotal: Int
        init() {
            let memory = Memory
            self.memoryFree  = memory?.free  ?? -1
            self.memoryUsed  = memory?.used  ?? -1
            self.memoryTotal = memory?.total ?? -1
        }
        // swiftlint:enable operator_usage_whitespace
    }
    
    struct ErrorDetails: Codable {
        
        static let NSValidationErrorObjectKey = "NSValidationErrorObject"
        static let NSValidationErrorKeyKey = "NSValidationErrorKey"
        static let NSValidationErrorValueKey = "NSValidationErrorValue"
        
        let code: Int
        let domain: String
        let localizedDescription: String?
        let localizedRecoveryOptions: [String]?
        let localizedRecoverySuggestion: String?
        let localizedFailureReason: String?
        let validationErrorObjectType: String? // NSValidationErrorObject
        let validationErrorKey: String? // NSValidationErrorKey
        let validationErrorValue: String? // NSValidationErrorValue
        let remainingKeys: [String: String]
        
        init(_ input: NSError) {
            // swiftlint:disable operator_usage_whitespace
            self.code = input.code
            self.domain = input.domain
            self.localizedDescription        = input.localizedDescription
            self.localizedRecoveryOptions    = input.localizedRecoveryOptions
            self.localizedRecoverySuggestion = input.localizedRecoverySuggestion
            self.localizedFailureReason      = input.localizedFailureReason
            self.validationErrorObjectType   = input.userInfo[ErrorDetails.NSValidationErrorObjectKey]
                                                    .map { String(describing: type(of: $0)) }
            self.validationErrorKey          = input.userInfo[ErrorDetails.NSValidationErrorKeyKey] as? String
            self.validationErrorValue        = input.userInfo[ErrorDetails.NSValidationErrorValueKey] as? String
            self.remainingKeys               = input.userInfo
                .compactMapValues { $0 as? String }
                .filter { key, _ in
                    return key != NSLocalizedDescriptionKey
                        && key != NSLocalizedRecoveryOptionsErrorKey
                        && key != NSLocalizedRecoverySuggestionErrorKey
                        && key != NSLocalizedFailureReasonErrorKey
                        && key != ErrorDetails.NSValidationErrorObjectKey
                        && key != ErrorDetails.NSValidationErrorKeyKey
                        && key != ErrorDetails.NSValidationErrorValueKey
            }
            // swiftlint:enable operator_usage_whitespace
        }
    }
}

extension XCGLogger.Level: Codable { }
extension UIDevice.BatteryState {
    var stringValue: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .unplugged:
            return "Unplugged"
        case .charging:
            return "Charging"
        case .full:
            return "Full"
        @unknown default:
            return "@unknown default"
        }
    }
}

private let LazyDiskCapacityCache: URLResourceValues? = {
    let fm = FileManager.default
    let dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    return try? dir?.resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey])
}()

private var Memory: (free: Int, used: Int, total: Int)? {
    // Below code is from StackOverflow by Nico
    // https://stackoverflow.com/a/8540665

    var pagesize: vm_size_t = 0

    let host_port: mach_port_t = mach_host_self()
    var host_size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
    host_page_size(host_port, &pagesize)

    var vm_stat: vm_statistics = vm_statistics_data_t()
    var failed = false
    withUnsafeMutablePointer(to: &vm_stat) { vmStatPointer -> Void in
        vmStatPointer.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
            if (host_statistics(host_port, HOST_VM_INFO, $0, &host_size) != KERN_SUCCESS) {
                NSLog("Error: Failed to fetch vm statistics")
                failed = true
            }
        }
    }
    guard !failed else { return nil }

    /* Stats in bytes */
    let mem_used = Int64(vm_stat.active_count
                         + vm_stat.inactive_count
                         + vm_stat.wire_count)
                         * Int64(pagesize)
    let mem_free = Int64(vm_stat.free_count)
                         * Int64(pagesize)
    /* Stats in MBytes */
    let mem_used_mb = Int(mem_used / 1000000)
    let mem_free_mb = Int(mem_free / 1000000)
    return (free: mem_free_mb, used: mem_used_mb, total: mem_used_mb + mem_free_mb)
}

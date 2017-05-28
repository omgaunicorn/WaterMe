//
//  Basics.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/9/17.
//
//

import XCGLogger

internal let log = XCGLogger.default

public protocol Resettable {
    func reset()
}

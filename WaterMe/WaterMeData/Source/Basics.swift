//
//  Basics.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/15/17.
//
//

import XCGLogger

internal let log = XCGLogger.default

public enum Result<T> {
    case error(Error), success(T)
}

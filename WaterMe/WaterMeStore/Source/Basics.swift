//
//  Basics.swift
//  Pods
//
//  Created by Jeffrey Bergier on 5/9/17.
//
//

public protocol Resettable {
    func reset()
}

public enum Result<T> {
    case error(Error), success(T)
}

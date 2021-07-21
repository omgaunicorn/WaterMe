//
//  Created by Jeffrey Bergier on 2021/01/28.
//
//  MIT License
//
//  Copyright (c) 2021 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Combine
import CoreData
import Collections

// TODO: Replace this file with original from Umbrella library
public typealias ErrorQueue = Deque<UserFacingError>

/// Represents the progress of something that is long running and can produce
/// errors upon startup and errors while running. I use this to reflect the status
/// of NSPersistentCloudKitContainer sync. But its generic enough to be used for
/// many types of long-running / background processes.
/// Use `AnyContinousProgress` to get around AssociatedType compile errors.
@available(iOS 13.0, *)
public protocol ContinousProgress: ObservableObject {
    associatedtype InitializeError: Swift.Error
    associatedtype QueueError: Swift.Error
    /// Fixed error that only occurs on startup and doesn't change
    /// for the lifetime of the process.
    var initializeError: InitializeError? { get }
    var progress: Progress { get }
    /// When an error occurs, append it to the Queue.
    var errorQ: Deque<QueueError> { get set }
}

@available(iOS 13.0, *)
public class AnyContinousProgress<InitError: Swift.Error, QError: Swift.Error>: ContinousProgress {
    
    public let objectWillChange: ObservableObjectPublisher
    public var initializeError: InitError? { _initializeError() }
    public var progress: Progress { _progress() }
    public var errorQ: Deque<QError> {
        get { _errorQ_get() }
        set { _errorQ_set(newValue) }
    }
    
    private var _initializeError: () -> InitError?
    private var _progress: () -> Progress
    private var _errorQ_get: () -> Deque<QError>
    private var _errorQ_set: (Deque<QError>) -> Void
    
    public init<T: ContinousProgress>(_ progress: T) where
        T.ObjectWillChangePublisher == ObservableObjectPublisher,
        T.InitializeError == InitError,
        T.QueueError == QError
    {
        self.objectWillChange = progress.objectWillChange
        _initializeError      = { progress.initializeError }
        _progress             = { progress.progress }
        _errorQ_get           = { progress.errorQ }
        _errorQ_set           = { progress.errorQ = $0 }
    }
}

/// Use when you have no progress to report
public class NoContinousProgress: ContinousProgress {
    public let initializeError: Swift.Error? = nil
    public let progress: Progress = .init()
    public var errorQ: Deque<Swift.Error> = .init()
    public init() {}
}

public enum GenericInitializationError: Swift.Error, RawRepresentable {
    
    case couldNotDetermine
    case restricted
    case noAccount
    
    public init?(rawValue: CKAccountStatus) {
        switch rawValue {
        case .available:
            return nil
        case .restricted:
            self = .restricted
        case .noAccount:
            self = .noAccount
        case .couldNotDetermine:
            fallthrough
        @unknown default:
            self = .couldNotDetermine
        }
    }
    
    public var rawValue: CKAccountStatus {
        switch self {
        case .couldNotDetermine:
            return .couldNotDetermine
        case .restricted:
            return .restricted
        case .noAccount:
            return .noAccount
        }
    }
}

public class CloudKitSyncError: TypedNSError<CloudKitSyncErrorKind> {
    public override class var errorDomain: String { "com.saturdayapps.waterme.CloudKitSyncError" }
}

// See CKError.h for all errors
public enum CloudKitSyncErrorKind: ErrorInitable {
    case password
    case network
    case unknown
    public init(_ _error: Error) {
        let error = _error as NSError
        guard error.domain == CKErrorDomain
            else { self = .unknown; return; }
        switch error.code {
        case 2: self = .password
        case 3: self = .network
        default: self = .unknown
        }
    }
}

//
//  RealmError.swift
//  WaterMeData
//
//  Created by Jeffrey Bergier on 8/12/17.
//

import Foundation

public struct RealmError: Error {
    public enum Kind {
        case loadError, createError, writeError, readError
    }
    public var kind: Kind
    public var error: Error
    internal init(kind: Kind, error: Error) {
        self.kind = kind
        self.error = error
    }
}

extension RealmError: UserFacingError {
    public var title: String {
        return "Error"
    }
    public var details: String? {
        switch self.kind {
        case .createError:
            return "Error creating save file. Check to make sure there is free space available on this device."
        case .loadError:
            return "Error loading save file. Check to make sure there is free space available on this device."
        case .readError:
            return "Error reading from save file. Check to make sure there is free space available on this device."
        case .writeError:
            return "Error saving changes. Check to make sure there is free space available on this device."
        }
    }
    public var actionTitle: String {
        return "Settings"
    }
}

//
//  LateInitialized.swift
//  TexDriveSDK
//
//  Created by A944VQ on 09/12/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import Foundation

#if canImport(Swiftui)
@available(swift 5.3)
@propertyWrapper
public struct LateInitialized<T> {
    internal var storage: T?
    
    public init() {
        storage = nil
    }
    
    public var wrappedValue: T {
        get {
            guard let value = storage else {
                fatalError("value has not been set!")
            }
            return value
        }
        set {
            storage = newValue
        }
    }
}

#endif

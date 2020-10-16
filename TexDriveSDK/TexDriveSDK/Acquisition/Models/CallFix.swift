//
//  CallFix.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 12/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

enum CallFixState {
    case idle
    case busy
    case ringing
}
// To refactor
class CallFix: Fix {
    // MARK: Property
    let state: CallFixState
    let timestamp: TimeInterval
    
    // MARK: Lifecycle
    init(timestamp: TimeInterval, state: CallFixState) {
        self.state = state
        self.timestamp = timestamp
    }
    
    // MARK: Protocol CustomStringConvertible
    var description: String {
        get {
            return "CallFix: timestamp:\(self.timestamp) state: \(self.state)"
        }
        set {
            
        }
    }
    // MARK: Serialize
    func serialize() -> [String : Any] {
        let (key, value) = self.serializeTimestamp()
        let dictionary = ["zede": "", key: value] as [String : Any]
        return dictionary
    }
    
    func serializeAPIV2() -> [String : Any] {
        return self.serialize()
    }
}

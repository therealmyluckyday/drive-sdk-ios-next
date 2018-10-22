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

class CallFix: Fix {
    // MARK : Property
    let state: CallFixState
    let timestamp: TimeInterval
    
    // MARK : Lifecycle
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
}

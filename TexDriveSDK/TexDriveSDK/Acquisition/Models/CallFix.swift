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
    
    // MARK : Lifecycle
    init(date: Date, callState: CallFixState) {
        state = callState
        super.init(date: date)
    }
    
    // MARK: Protocol CustomStringConvertible
    override var description: String {
        get {
            return "CallFix: date:\(self.timestamp) state: \(self.state)"
        }
        set {
            
        }
    }
}

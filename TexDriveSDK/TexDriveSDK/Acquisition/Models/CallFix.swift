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
    let timestamp: Date
    let state: CallFixState
    
    // MARK : Lifecycle
    init(date: Date, callState: CallFixState) {
        timestamp = date
        state = callState
    }
}

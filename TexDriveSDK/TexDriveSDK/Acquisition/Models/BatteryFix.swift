//
//  BatteryFix.swift
//  TexDriveSDK
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

enum BatteryState {
    
    case plugged
    case unplugged
    case unknown
}

class BatteryFix : Fix {
    // MARK: Property
    let level: Float
    let state: BatteryState
    let timestamp: Date
    
    // MARK: LifeCycle
    init (timestamp: Date, level: Float, state: BatteryState) {
        self.level = level
        self.state = state
        self.timestamp = timestamp
    }
}

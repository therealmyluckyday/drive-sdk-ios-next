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
    
    // MARK: LifeCycle
    init (timestamp: Date, level: Float, state: BatteryState) {
        self.level = level
        self.state = state
        super.init(date: timestamp)
    }
    
    // MARK: Protocol CustomStringConvertible
    override var description: String {
        get {
            return "BATTERYFIX: date:\(self.timestamp) state: \(self.state), level: \(self.level)"
        }
        set {
            
        }
    }
}

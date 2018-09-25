//
//  BatteryFix.swift
//  TexDriveSDK
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

class BatteryFix : Fix {
    
    var level: Float
    var state: BatteryState
    
    init (fixId: String, timestamp: Date, level: Float = 0, state: BatteryState = .unknown) {
        self.level = level
        self.state = state
        super.init(fixId: fixId, timestamp: timestamp)
    }
}

//
//  BatteryFix.swift
//  TexDriveSDK
//
//  Created by Axa on 11/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

enum BatteryState: String {
    case plugged = "plugged"
    case unplugged = "unplugged"
    case unknown = "unknown"
}

class BatteryFix : Fix {
    // MARK: Property
    let level: Float
    let state: BatteryState
    let timestamp: TimeInterval
    
    // MARK: LifeCycle
    init (timestamp: TimeInterval, level: Float, state: BatteryState) {
        self.level = level
        self.state = state
        self.timestamp = timestamp
    }
    
    // MARK: Protocol CustomStringConvertible
    var description: String {
        get {
            return "BATTERYFIX: timestamp:\(self.timestamp) state: \(self.state), level: \(self.level)"
        }
        set {
            
        }
    }
    
    // MARK: Serialize
    func serialize() -> [String : Any] {
        let (key, value) = self.serializeTimestamp()
        let dictionary = ["battery": self.serializeBattery(), key: value] as [String : Any]
        return dictionary
    }
    
    private func serializeBattery() -> [String: Any] {
        return ["level": Int(self.level > 0 ? self.level*100 : 0 ), "state": self.state.rawValue]
    }
    
    func serializeAPIV2() -> [String : Any] {
        return self.serialize()
    }
}

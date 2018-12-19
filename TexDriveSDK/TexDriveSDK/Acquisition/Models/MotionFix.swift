//
//  MotionFix.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 16/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreMotion

//let MaxDecimalPlacesSerialization = 6

struct ConstantMotion {
    static let gravity = 9.81
}

struct XYZAxisValues: Equatable {
    let x: Double
    let y: Double
    let z: Double
}

class MotionFix: Fix {
    // MARK: Property
    let timestamp: TimeInterval
    let acceleration: XYZAxisValues
    let gravity: XYZAxisValues
    let magnetometer: XYZAxisValues
    let isCrashDetected: Bool
    
    
    // MARK: Lifecycle
    init(timestamp: TimeInterval, accelerationMotion: XYZAxisValues, gravityMotion: XYZAxisValues, magnetometerMotion: XYZAxisValues, crashDetected: Bool) {
        let startupDate = Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)
        self.timestamp = Date(timeInterval: timestamp, since: startupDate).timeIntervalSince1970
        acceleration = accelerationMotion
        gravity = gravityMotion
        magnetometer = magnetometerMotion
        isCrashDetected = crashDetected
    }
    
    // MARK: Protocol CustomStringConvertible
    var description: String {
        get {
            var description = "MotionFix: motionTimestamp: \(self.timestamp), acceleration: \(self.acceleration)"
            description += "MotionFix: gravity:\(self.gravity) magnetometer: \(self.magnetometer), isCrashDetected: \(self.isCrashDetected)"
            return description
        }
        set {
            
        }
    }
    
    // MARK: Serialize
    func serialize() -> [String : Any] {
        let (key, value) = self.serializeTimestamp()
        let dictionary = ["motion": self.serializeMotion(), key: value] as [String : Any]
        return dictionary
    }
    
    private func serializeMotion() -> [String: Any] {
        return ["magnetometer": self.serializeXYZAxisValues(value: magnetometer), "gravity": self.serializeXYZAxisValues(value: self.gravity), "acceleration": self.serializeXYZAxisValues(value: self.acceleration)]
    }
    
    private func serializeXYZAxisValues(value: XYZAxisValues) -> [String: Double] {
        return ["x": value.x, "y": value.y, "z": value.z]
    }
}
// @(roundToDecimal(motion.userAcceleration.x * GravityConstant, AXAMaxDecimalPlaces));
// Extension use to convert CMDeviceMotion to MotionFix
extension MotionFix {
    // MARK: Public Method
    /**
     Returns the L2 norm of the acceleration (including gravity) from a CMDeviceMotion.
     */
    class func normL2Acceleration(motion: CMDeviceMotion) -> Double {
        let x = motion.gravity.x + motion.userAcceleration.x;
        let y = motion.gravity.y + motion.userAcceleration.y;
        let z = motion.gravity.z + motion.userAcceleration.z;
        return pow(x*x + y*y + z*z, 0.5);
    }
    
    func normL2Acceleration() -> Double {
        let x = self.gravity.x + self.acceleration.x;
        let y = self.gravity.y + self.acceleration.y;
        let z = self.gravity.z + self.acceleration.z;
        return pow(x*x + y*y + z*z, 0.5);
    }
    
    class func convert(acceleration: CMAcceleration) -> XYZAxisValues {
        let x = acceleration.x * ConstantMotion.gravity
        let y = acceleration.y * ConstantMotion.gravity
        let z = acceleration.z * ConstantMotion.gravity
        return XYZAxisValues(x: x, y: y, z: z)
    }
    
    class func convert(field: CMMagneticField) -> XYZAxisValues {
        let x = field.x
        let y = field.y
        let z = field.z
        return XYZAxisValues(x: x, y: y, z: z)
    }
}
extension MotionFix: Equatable {
    // MARK : Equatable
    static func == (lhs: MotionFix, rhs: MotionFix) -> Bool {
        return (lhs.acceleration == rhs.acceleration) && (lhs.magnetometer == rhs.magnetometer) && (lhs.gravity == rhs.gravity) && (lhs.timestamp == rhs.timestamp) && (lhs.isCrashDetected == rhs.isCrashDetected)
    }
}

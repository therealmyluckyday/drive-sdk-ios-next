//
//  MotionFix.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 16/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreMotion

let GravityConstant = 9.81
//let MaxDecimalPlacesSerialization = 6

struct XYZAxisValues  {
    let x: Float
    let y: Float
    let z: Float
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
        self.timestamp = timestamp
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
    
    func normL2Acceleration() -> Float {
        let x = self.gravity.x + self.acceleration.x;
        let y = self.gravity.y + self.acceleration.y;
        let z = self.gravity.z + self.acceleration.z;
        return pow(x*x + y*y + z*z, 0.5);
    }
    
    class func convert(acceleration: CMAcceleration) -> XYZAxisValues {
        let x = Float(acceleration.x * GravityConstant)
        let y = Float(acceleration.y * GravityConstant)
        let z = Float(acceleration.z * GravityConstant)
        return XYZAxisValues(x: x, y: y, z: z)
    }
    
    class func convert(field: CMMagneticField) -> XYZAxisValues {
        let x = Float(field.x)
        let y = Float(field.y)
        let z = Float(field.z)
        return XYZAxisValues(x: x, y: y, z: z)
    }
}

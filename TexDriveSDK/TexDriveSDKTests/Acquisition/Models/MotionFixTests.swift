//
//  MotionFixTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 18/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CoreMotion

@testable import TexDriveSDK

class MockCMDeviceMotion: CMDeviceMotion {
    var mockGravity: CMAcceleration
    var mockAcceleration: CMAcceleration
    
    override var gravity: CMAcceleration {
        get {
            return mockGravity
        }
    }
    
    override var userAcceleration: CMAcceleration {
        get {
            return mockAcceleration
        }
    }
    
    init(userAcceleration: CMAcceleration, gravity: CMAcceleration) {
        mockAcceleration = userAcceleration
        mockGravity = gravity
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MotionFixTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: init()
    func testInit() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 0, y: 1, z: 2)
        let gavityMotion = XYZAxisValues(x: 3, y: 4, z: 5)
        let magnetometerMotion = XYZAxisValues(x: 6, y: 7, z: 8)
        
        let motion = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gavityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        let realtimestamp = Date(timeInterval: timestamp, since: Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
        XCTAssertEqual(motion.timestamp.rounded(), realtimestamp.rounded())
        XCTAssertEqual(motion.acceleration.x, 0)
        XCTAssertEqual(motion.acceleration.y, 1)
        XCTAssertEqual(motion.acceleration.z, 2)
        XCTAssertEqual(motion.gravity.x, 3)
        XCTAssertEqual(motion.gravity.y, 4)
        XCTAssertEqual(motion.gravity.z, 5)
        XCTAssertEqual(motion.magnetometer.x, 6)
        XCTAssertEqual(motion.magnetometer.y, 7)
        XCTAssertEqual(motion.magnetometer.z, 8)
        XCTAssertTrue(motion.isCrashDetected)
        
        let motionNotCrash = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gavityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        XCTAssertFalse(motionNotCrash.isCrashDetected)
    }
    
    // MARK: class func normL2Acceleration(motion: CMDeviceMotion) -> Double
    func testNormL2AccelerationClassWithCMDeviceMotion_Zero() {
        let acceleration = CMAcceleration(x: 0, y: 0, z: 0)
        let gravity = CMAcceleration(x: 0, y: 0, z: 0)
        let motion = MockCMDeviceMotion(userAcceleration: acceleration, gravity: gravity)
        
        let result = MotionFix.normL2Acceleration(motion: motion)
        
        XCTAssertEqual(result, 0)
    }
    
    func testNormL2AccelerationClassWithCMDeviceMotion_Test() {
        let acceleration = CMAcceleration(x: 1, y: 2, z: 3)
        let gravity = CMAcceleration(x: 4, y: 5, z: 6)
        let motion = MockCMDeviceMotion(userAcceleration: acceleration, gravity: gravity)
        
        let result = MotionFix.normL2Acceleration(motion: motion)
        
        XCTAssertEqual(String(result), String(12.449899597988733))
    }
    
    // MARK: func normL2Acceleration() -> Float
    func testNormL2AccelerationWithMotion_Zero() {
        let acceleration = XYZAxisValues(x: 0, y: 0, z: 0)
        let gravity = XYZAxisValues(x: 0, y: 0, z: 0)
        let magnetometerMotion = XYZAxisValues(x: 0, y: 0, z: 0)
        let motion = MotionFix(timestamp: 0, accelerationMotion: acceleration, gravityMotion: gravity, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        let result = motion.normL2Acceleration()
        
        XCTAssertEqual(result, 0)
    }
    
    func testNormL2AccelerationMotion_Test() {
        let acceleration = XYZAxisValues(x: 1, y: 2, z: 3)
        let gravity = XYZAxisValues(x: 4, y: 5, z: 6)
        let magnetometerMotion = XYZAxisValues(x: 0, y: 0, z: 0)
        let motion = MotionFix(timestamp: 0, accelerationMotion: acceleration, gravityMotion: gravity, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        let result = motion.normL2Acceleration()
        
        XCTAssertEqual(String(result), String(12.449899597988733))
    }
    
    // MARK: class func convert(acceleration: CMAcceleration) -> XYZAxisValues
    func testConvertAccelerationWithZeroValues() {
        let accelerationCM = CMAcceleration(x: 0, y: 0, z: 0)
        
        let accelerationXYZ = MotionFix.convert(acceleration: accelerationCM)
        
        XCTAssertEqual(accelerationXYZ.x, 0)
        XCTAssertEqual(accelerationXYZ.y, 0)
        XCTAssertEqual(accelerationXYZ.z, 0)
    }
    
    func testConvertAccelerationWithValues() {
        let accelerationCM = CMAcceleration(x: 1, y: 2, z: 3)
        
        let accelerationXYZ = MotionFix.convert(acceleration: accelerationCM)
        
        XCTAssertEqual(accelerationXYZ.x, 9.81)
        XCTAssertEqual(accelerationXYZ.y, 2*9.81)
        XCTAssertEqual(accelerationXYZ.z, 3*9.81)
    }
    
    // MARK: class func convert(field: CMMagneticField) -> XYZAxisValues
    func testConvertMagneticFieldWithZeroValue() {
        let gravity = CMMagneticField(x: 0, y: 0, z: 0)
        
        let gravityXYZ = MotionFix.convert(field: gravity)
        
        
        XCTAssertEqual(gravityXYZ.x, 0)
        XCTAssertEqual(gravityXYZ.y, 0)
        XCTAssertEqual(gravityXYZ.z, 0)
    }
    
    func testConvertMagneticFieldWithValues() {
        let gravity = CMMagneticField(x: 4, y: 5, z: 6)
        
        let gravityXYZ = MotionFix.convert(field: gravity)
        
        
        XCTAssertEqual(gravityXYZ.x, 4)
        XCTAssertEqual(gravityXYZ.y, 5)
        XCTAssertEqual(gravityXYZ.z, 6)
    }
    
    
    // MARK: func serialize() -> [String : Any]
    func testSerialize() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 0.8118888188181, y: 1.8118888188181, z: 2.8118881188181)
        let gravityMotion = XYZAxisValues(x: 3.8118888188181, y: 4.8118888188181, z: 5.8118881188181)
        let magnetometerMotion = XYZAxisValues(x: 6.8118888188181, y: 7.8118888188181, z: 8.8118881188181)
        
        let motionFix = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        
        let result = motionFix.serialize()
        
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        let realtimestamp = Date(timeInterval: timestamp, since: Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
        XCTAssertEqual(result["timestamp"] as! Int, Int(realtimestamp*1000))
        let detailResult = result["motion"] as! [String : Any]
        let magnetometerResult = detailResult["magnetometer"] as! [String : Any]
        XCTAssertEqual(magnetometerResult["x"] as! Double, magnetometerMotion.x)
        XCTAssertEqual(magnetometerResult["y"] as! Double, magnetometerMotion.y)
        XCTAssertEqual(magnetometerResult["z"] as! Double, magnetometerMotion.z)
        let gravityResult = detailResult["gravity"] as! [String : Any]
        XCTAssertEqual(gravityResult["x"] as! Double, gravityMotion.x)
        XCTAssertEqual(gravityResult["y"] as! Double, gravityMotion.y)
        XCTAssertEqual(gravityResult["z"] as! Double, gravityMotion.z)
        let accelerationResult = detailResult["acceleration"] as! [String : Any]
        XCTAssertEqual(accelerationResult["x"] as! Double, accelerationMotion.x)
        XCTAssertEqual(accelerationResult["y"] as! Double, accelerationMotion.y)
        XCTAssertEqual(accelerationResult["z"] as! Double, accelerationMotion.z)
    }
}

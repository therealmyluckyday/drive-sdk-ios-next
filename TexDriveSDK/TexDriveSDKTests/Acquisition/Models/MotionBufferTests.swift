//
//  MotionBuffer.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 17/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class MotionBufferTests: XCTestCase {
    
    func testAppend_Trigger_Crash_0SecondsAfter() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let gravityMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let magnetometerMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let motion1 = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        let motionCrash = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        
        let motionBuffer = MotionBuffer(futureBufferSizeInSecond: 0)
        
        var isSend = false
        let subscribe = motionBuffer.rx_crashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
            
            XCTAssertNotNil(event.element)
            print("---------------------------")
            print("DISPATCH")
            if let motionsFix = event.element {
                print("\(motionsFix)")
                XCTAssertEqual(motionsFix.count, 3)
                XCTAssertEqual(motionsFix[0].timestamp, timestamp)
                XCTAssertEqual(motionsFix[1].timestamp, timestamp)
                XCTAssertEqual(motionsFix[2].timestamp, timestamp)
            }
        })
        print("---------------------------")
        print("-------MOTION 1--------------------")
        print("---------------------------")
        motionBuffer.append(fix:motion1)
        
        print("---------------------------")
        print("-------MOTION 2 CRASH--------------------")
        print("---------------------------")
        motionBuffer.append(fix: motionCrash)
        
        print("---------------------------")
        print("-------MOTION 3--------------------")
        print("---------------------------")
        motionBuffer.append(fix: motion1)
        
        print("---------------------------")
        print("-------MOTION 4--------------------")
        print("---------------------------")
        motionBuffer.append(fix: motion1)
        
        print("---------------------------")
        print("-------END--------------------")
        print("---------------------------")
        subscribe.dispose()
        XCTAssertTrue(isSend)
    }
}

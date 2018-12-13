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
        let realtimestamp = Date(timeInterval: timestamp, since: Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
        let subscribe = motionBuffer.rxCrashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
            XCTAssertNotNil(event.element)
            if let motionsFix = event.element {
                XCTAssertEqual(motionsFix.count, 3)
                XCTAssertEqual(motionsFix[0].timestamp.rounded(), realtimestamp.rounded())
                XCTAssertEqual(motionsFix[1].timestamp.rounded(), realtimestamp.rounded())
                XCTAssertEqual(motionsFix[2].timestamp.rounded(), realtimestamp.rounded())
            }
        })

        motionBuffer.append(fix:motion1)
        motionBuffer.append(fix: motionCrash)
        motionBuffer.append(fix: motion1)
        motionBuffer.append(fix: motion1)
        
        XCTAssertTrue(isSend)
        subscribe.dispose()
    }
}

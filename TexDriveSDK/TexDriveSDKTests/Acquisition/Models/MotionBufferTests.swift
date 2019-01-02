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
    // MARK : func append(fix: MotionFix)
    func testAppend_Trigger_Crash_0SecondsAfter() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let gravityMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let magnetometerMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let motionBegin = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
        let motionEnd = MotionFix(timestamp: timestamp+0.1, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        let motionCrash = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        
        let motionBuffer = MotionBuffer(futureBufferSizeInSecond: 0)
        
        var isSend = false
        let realtimestamp = Date(timeInterval: timestamp, since: Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
        let subscribe = motionBuffer.rxCrashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
            XCTAssertNotNil(event.element)
            if let motionsFix = event.element {
                XCTAssertEqual(motionsFix.count, 2)
                XCTAssertEqual(motionsFix[0].timestamp.rounded(), realtimestamp.rounded())
                XCTAssertEqual(motionsFix[1].timestamp.rounded(), realtimestamp.rounded())
            }
        })
        
        motionBuffer.append(fix:motionBegin)
        motionBuffer.append(fix: motionCrash)
        motionBuffer.append(fix: motionEnd)
        motionBuffer.append(fix: motionEnd)
        
        XCTAssertTrue(isSend)
        subscribe.dispose()
    }
    
    func testAppend_Not_Trigger_Crash_0SecondsAfter() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let gravityMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let magnetometerMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let motion1 = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        let motionCrash = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        
        let motionBuffer = MotionBuffer(futureBufferSizeInSecond: 5)
        
        var isSend = false
        let realtimestamp = Date(timeInterval: timestamp, since: Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
        let subscribe = motionBuffer.rxCrashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
        })
        
        motionBuffer.append(fix:motion1)
        motionBuffer.append(fix: motionCrash)
        motionBuffer.append(fix: motion1)
        motionBuffer.append(fix: motion1)
        
        XCTAssertFalse(isSend)
        subscribe.dispose()
    }
    func testAppend_Trigger_Crash_5SecondsAfter() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let gravityMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let magnetometerMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let motion1 = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        let motionCrash = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        
        
        let motionFinished = MotionFix(timestamp: timestamp + 6, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
        
        let motionBuffer = MotionBuffer(futureBufferSizeInSecond: 5)
        
        var isSend = false
        let realtimestamp = Date(timeInterval: timestamp, since: Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
        let subscribe = motionBuffer.rxCrashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
            XCTAssertNotNil(event.element)
            if let motionsFix = event.element {
                XCTAssertEqual(motionsFix.count, 4)
                XCTAssertEqual(motionsFix[0].timestamp.rounded(), realtimestamp.rounded())
                XCTAssertEqual(motionsFix[1].timestamp.rounded(), realtimestamp.rounded())
                XCTAssertEqual(motionsFix[2].timestamp.rounded(), realtimestamp.rounded())
                XCTAssertEqual(motionsFix[3].timestamp.rounded(), realtimestamp.rounded())
            }
        })
        
        motionBuffer.append(fix:motion1)
        motionBuffer.append(fix: motionCrash)
        motionBuffer.append(fix: motion1)
        motionBuffer.append(fix: motion1)
        motionBuffer.append(fix: motionFinished)
        
        XCTAssertTrue(isSend)
        subscribe.dispose()
    }
    
    func testAppend_Trigger_2Crash_5SecondsAfter() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let gravityMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let magnetometerMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let crashHighestMotion = XYZAxisValues(x: 10, y: 10, z: 10)
        
        let motionCrashHighest = MotionFix(timestamp: timestamp, accelerationMotion: crashHighestMotion, gravityMotion: crashHighestMotion, magnetometerMotion: crashHighestMotion, crashDetected: true)

        let motionCrash = MotionFix(timestamp: timestamp + TimeInterval(4.96), accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)

        
        let motionBuffer = MotionBuffer(futureBufferSizeInSecond: 5)
        
        var isSend = false

        let subscribe = motionBuffer.rxCrashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
            XCTAssertNotNil(event.element)
            if let motionsFix = event.element {

                XCTAssert(motionsFix.count > 1490)
                XCTAssert(motionsFix.count < 1501)
                XCTAssert(motionsFix.first!.timestamp < motionCrashHighest.timestamp - 9, "motionsFix.first!.timestamp \(motionsFix.first!.timestamp) motionCrashHighest.timestamp \(motionCrashHighest.timestamp)")
                XCTAssert(motionsFix.last!.timestamp > motionCrashHighest.timestamp + 4.9)
            }
        })
        
        for i in 0...1600 {
            let motionhz = MotionFix(timestamp: (timestamp - 16) + TimeInterval(i/100), accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
            motionBuffer.append(fix:motionhz)
        }
        

        motionBuffer.append(fix: motionCrashHighest)
        
        for i in 1...496 {
            let motionhz = MotionFix(timestamp: timestamp + TimeInterval(i/100), accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
            motionBuffer.append(fix:motionhz)
        }

        motionBuffer.append(fix: motionCrash)
        
        for i in 1...800 {
            let time = TimeInterval(timestamp + Double(4.95) + Double(i/100))
            let motionhz = MotionFix(timestamp: time, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)

            motionBuffer.append(fix:motionhz)
        }
        XCTAssertTrue(isSend)
        subscribe.dispose()
    }
    
    func testAppend_Trigger_2Crash_HighestCrashSecond_5SecondsAfter() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let gravityMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let magnetometerMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let crashHighestMotion = XYZAxisValues(x: 10, y: 10, z: 10)
        
        let motionCrashHighest = MotionFix(timestamp: timestamp + TimeInterval(4.96), accelerationMotion: crashHighestMotion, gravityMotion: crashHighestMotion, magnetometerMotion: crashHighestMotion, crashDetected: true)

        let motionCrash = MotionFix(timestamp: timestamp , accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)

        
        let motionBuffer = MotionBuffer(futureBufferSizeInSecond: 5)
        
        var isSend = false
        
        let subscribe = motionBuffer.rxCrashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
            XCTAssertNotNil(event.element)
            if let motionsFix = event.element {
                XCTAssert(motionsFix.count > 1490)
                XCTAssert(motionsFix.count < 1501)
                XCTAssert(motionsFix.first!.timestamp < motionCrashHighest.timestamp - 9)
                XCTAssert(motionsFix.first!.timestamp > motionCrashHighest.timestamp - 11)
                XCTAssert(motionsFix.last!.timestamp > motionCrashHighest.timestamp + 4.8)
                XCTAssert(motionsFix.last!.timestamp < motionCrashHighest.timestamp + 5.1)
            }
        })
        
        for i in 0...1000 {
            let motionhz = MotionFix(timestamp: (timestamp - 10) + TimeInterval(i/100), accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
            motionBuffer.append(fix:motionhz)
        }
        

        motionBuffer.append(fix: motionCrash)
        

        for i in 1...496 {
            let motionhz = MotionFix(timestamp: timestamp + TimeInterval(i/100), accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
            motionBuffer.append(fix:motionhz)
        }

        motionBuffer.append(fix: motionCrashHighest)
        
        for i in 1...800 {
            let time = TimeInterval(timestamp + Double(4.96) + Double(i/100))
            let motionhz = MotionFix(timestamp: time, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
            motionBuffer.append(fix:motionhz)
        }
        XCTAssertTrue(isSend)
        subscribe.dispose()
    }
    
    func testAppend_NoTrigger_5SecondsAfter() {
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let gravityMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let magnetometerMotion = XYZAxisValues(x: 1, y: 1, z: 1)
        let motionBuffer = MotionBuffer(futureBufferSizeInSecond: 5)
        var isSend = false

        let subscribe = motionBuffer.rxCrashMotionFix.asObservable().subscribe({ (event) in
            isSend = true
        })
        for i in 0...2000 {
            let time = TimeInterval((timestamp - 10) + Double(i/100))
            let motionhz = MotionFix(timestamp: time, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: false)
            motionBuffer.append(fix:motionhz)
        }
        
        XCTAssertFalse(isSend)
        subscribe.dispose()
    }

}

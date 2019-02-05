//
//  MotionTrackerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 18/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import CoreMotion

@testable import TexDriveSDK

class StubMotionSensor: CMMotionManager {
    var isStopDeviceMotionUpdatesCalled = false
    var isStartDeviceMotionUpdateCalled = false
    
    override func stopDeviceMotionUpdates() {
        isStopDeviceMotionUpdatesCalled = true
        super.stopDeviceMotionUpdates()
    }
    override func startDeviceMotionUpdates(using referenceFrame: CMAttitudeReferenceFrame, to queue: OperationQueue, withHandler handler: @escaping CMDeviceMotionHandler) {
        isStartDeviceMotionUpdateCalled = true
    }
}


class MotionTrackerTests: XCTestCase {
    // MARK: func disableTracking()
    func testDisableTracking_CallFunction() {
        let mock = StubMotionSensor()
        let tracker = MotionTracker(sensor: mock, scheduler: MainScheduler.instance)

        tracker.disableTracking()
        
        XCTAssertTrue(mock.isStopDeviceMotionUpdatesCalled)
        XCTAssertFalse(mock.isStartDeviceMotionUpdateCalled)
    }
    func testDisableTracking_Unsubscribe() {
        let mock = StubMotionSensor()
        let motionBuffer = MotionBuffer()
        let tracker = MotionTracker(sensor: mock, scheduler: MainScheduler.instance, buffer: motionBuffer)
        let motionFix = MotionFix(timestamp: 999999, accelerationMotion: XYZAxisValues(x: 9, y: 9, z: 9), gravityMotion: XYZAxisValues(x: 9, y: 9, z: 9), magnetometerMotion: XYZAxisValues(x: 9, y: 9, z: 9), crashDetected: false)
        let motionFixes = [motionFix]
        tracker.enableTracking()
        tracker.disableTracking()
        XCTAssertTrue(mock.isStopDeviceMotionUpdatesCalled)
        var isSubscribeCalled = false
        let rxMotionProviderFix = tracker.provideFix()
        let dispose = rxMotionProviderFix.subscribe { (event) in
            isSubscribeCalled = true
        }
        
        motionBuffer.rxCrashMotionFix.onNext(motionFixes)
        XCTAssertFalse(isSubscribeCalled)
        dispose.dispose()
    }
    // MARK: - func enableTracking()
    func testEnableTracking_FunctionCalled() {
        let mock = StubMotionSensor()
        let tracker = MotionTracker(sensor: mock, scheduler: MainScheduler.instance)
        
        tracker.enableTracking()
        
        XCTAssertFalse(mock.isStopDeviceMotionUpdatesCalled)
        XCTAssertTrue(mock.isStartDeviceMotionUpdateCalled)
    }
    
    func testEnableTracking_Subscribe() {
        let mock = StubMotionSensor()
        let motionBuffer = MotionBuffer()
        let tracker = MotionTracker(sensor: mock, scheduler: MainScheduler.instance, buffer: motionBuffer)
        let motionFix = MotionFix(timestamp: 999999, accelerationMotion: XYZAxisValues(x: 9, y: 9, z: 9), gravityMotion: XYZAxisValues(x: 9, y: 9, z: 9), magnetometerMotion: XYZAxisValues(x: 9, y: 9, z: 9), crashDetected: false)
        let motionFixes = [motionFix]
        tracker.enableTracking()
        tracker.disableTracking()
        tracker.enableTracking()
        
        XCTAssertTrue(mock.isStartDeviceMotionUpdateCalled)
        var isSubscribeCalled = false
        let rxMotionProviderFix = tracker.provideFix()
        let dispose = rxMotionProviderFix.subscribe { (event) in
            isSubscribeCalled = true
            guard let result = event.element else {
                XCTAssert(false)
                return
            }
            switch result {
            case Result.Success(let motionResult):
                XCTAssertEqual(motionResult, motionFix)
                break
            default:
                XCTAssert(false)
            }
        }
        
        motionBuffer.rxCrashMotionFix.onNext(motionFixes)
        XCTAssertTrue(isSubscribeCalled)
        dispose.dispose()
    }
}

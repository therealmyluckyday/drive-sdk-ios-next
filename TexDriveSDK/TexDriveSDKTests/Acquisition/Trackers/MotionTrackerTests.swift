//
//  MotionTrackerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 18/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CoreMotion

@testable import TexDriveSDK

class MockMotionSensor: CMMotionManager {
    var isStopDeviceMotionUpdatesCalled = false
    var isStartDeviceMotionUpdateCalled = false
    
    override func stopDeviceMotionUpdates() {
        isStopDeviceMotionUpdatesCalled = true
    }
    override func startDeviceMotionUpdates(using referenceFrame: CMAttitudeReferenceFrame, to queue: OperationQueue, withHandler handler: @escaping CMDeviceMotionHandler) {
        isStartDeviceMotionUpdateCalled = true
    }
}

class MotionTrackerTests: XCTestCase {
    
    // MARK : func disableTracking()
    func testDisableTracking() {
        let mock = MockMotionSensor()
        let tracker = MotionTracker(sensor: mock)
        
        tracker.disableTracking()
        
        XCTAssertTrue(mock.isStopDeviceMotionUpdatesCalled)
        XCTAssertFalse(mock.isStartDeviceMotionUpdateCalled)
    }
    
    func testEnableTracking() {
        let mock = MockMotionSensor()
        let tracker = MotionTracker(sensor: mock)
        
        tracker.enableTracking()
        
        XCTAssertFalse(mock.isStopDeviceMotionUpdatesCalled)
        XCTAssertTrue(mock.isStartDeviceMotionUpdateCalled)
    }
    
}

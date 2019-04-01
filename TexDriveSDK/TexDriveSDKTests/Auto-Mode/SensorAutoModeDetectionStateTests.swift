//
//  SensorAutoModeDetectionStateTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 25/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest
import CoreLocation
@testable import TexDriveSDK
@testable import RxSwift

class MockSensorAutoModeDetectionState: SensorAutoModeDetectionState {
    var isEnableSensorCalled = false
    override func enableSensor() {
        isEnableSensorCalled = true
        super.enableSensor()
    }
    var isEnableLocationSensorCalled = false
    override func enableLocationSensor() {
        super.enableLocationSensor()
        isEnableLocationSensorCalled = true
    }
    
    var isEnableMotionSensorCalled = false
    override func enableMotionSensor() {
        super.enableMotionSensor()
        isEnableMotionSensorCalled = true
    }
    
    var isDisableSensorCalled = false
    override func disableSensor() {
        isDisableSensorCalled = true
        super.disableSensor()
    }
    var isDisableLocationSensorCalled = false
    override func disableLocationSensor() {
        super.disableLocationSensor()
        isDisableLocationSensorCalled = true
    }
    var isDisableMotionSensorCalled = false
    override func disableMotionSensor() {
        super.disableMotionSensor()
        isDisableMotionSensorCalled = true
    }
    
    var isDidUpdateLocationCalled = false
    override func didUpdateLocations(location: CLLocation) {
        super.didUpdateLocations(location: location)
        isDidUpdateLocationCalled = true
    }
}

class SensorAutoModeDetectionStateTests: XCTestCase {
    var disposeBag = DisposeBag()
    let context = StubAutoModeContextProtocol()
    
    func testEnable() {
        let state = MockSensorAutoModeDetectionState(context: context, locationManager: LocationManager())
        state.enable()
        XCTAssertTrue(state.isEnableSensorCalled)
    }
    
    func testEnableSensor() {
        let state = MockSensorAutoModeDetectionState(context: context, locationManager: LocationManager())
        state.enableSensor()
        XCTAssertTrue(state.isEnableLocationSensorCalled)
        XCTAssertTrue(state.isEnableMotionSensorCalled)
    }
    
    func testDisable() {
        let state = MockSensorAutoModeDetectionState(context: context, locationManager: LocationManager())
        state.disable()
        XCTAssert(state.isDisableSensorCalled)
    }
    
    func testDisableSensor() {
        let state = MockSensorAutoModeDetectionState(context: context, locationManager: LocationManager())
        state.disableSensor()
        XCTAssert(state.isDisableLocationSensorCalled)
        XCTAssert(state.isDisableMotionSensorCalled)
    }
}

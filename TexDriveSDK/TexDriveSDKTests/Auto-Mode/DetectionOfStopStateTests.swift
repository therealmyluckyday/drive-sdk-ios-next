//
//  DetectionOfStopStateTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 20/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest
import CoreLocation
import CoreMotion
@testable import TexDriveSDK
@testable import RxSwift

class DetectionOfStopStateTests: XCTestCase {
    var disposeBag = DisposeBag()
    let context = StubAutoModeContextProtocol()
    
    func testStop() {
        let state = DetectionOfStopState(context: context, locationManager: LocationManager())
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is StandbyState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.stop()
        wait(for: [expectation], timeout: 1)
    }
    
    func testDrive() {
        let state = DetectionOfStopState(context: context, locationManager: LocationManager())
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DrivingState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.drive()
        wait(for: [expectation], timeout: 1)
    }
    
    func testDisable() {
        let state = DetectionOfStopState(context: context, locationManager: LocationManager())
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DisabledState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.disable()
        wait(for: [expectation], timeout: 1)
    }
    
    
    /*
     Scenario: From DetectionOfStopState to DrivingState state
     Given the automode in the Stopped state for less than 3 minutes
     When a GPS point with a speed higher than 10 km/h is received
     Then the state machine goes to the Driving state
     */
    func testHighSpeed() {
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            expectation.fulfill()
            }.disposed(by: disposeBag)

        let state = DetectionOfStopState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        state.sensorState = .enable
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 9, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime178SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 11, timestamp: Date().addingTimeInterval(178))
        state.didUpdateLocations(location: locationTime178SecondAfter)

        wait(for: [expectation], timeout: 1)
    }
    
    /*
     Scenario: From DetectionOfStopState to StandbyState state
     Given the automode in the Stopped state
     When any GPS with speed higher than 10 km/h is received for 3 minutes
     Then the state machine goes to the StandbyState state
     */
    
    func testLowSpeed() {
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is StandbyState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        
        let state = DetectionOfStopState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        state.sensorState = .enable
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime178SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date().addingTimeInterval(178))
        state.didUpdateLocations(location: locationTime178SecondAfter)
        
        let locationTime181SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date().addingTimeInterval(181))
        state.didUpdateLocations(location: locationTime181SecondAfter)
        
        wait(for: [expectation], timeout: 1)
    }
    
    /*
     Scenario: From DetectionOfStopState state to StandbyState state
     Given the automode in the Stopped or Driving state
     When any GPS is received for longer than 4 minutes
     Then the state machine goes to the StandbyState state
     */
    func testDetectionOfStopToDetectionOfStartStopCalled4minNoGPS() {
    }
    
    func testDrivingToDetectionOfStartStopCalled4minNoGPS() {
    }
    
    
    func testDoNothing() {
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            expectation.fulfill()
            }.disposed(by: disposeBag)
        
        let state = DetectionOfStopState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 9, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime178SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 11, timestamp: Date().addingTimeInterval(178))
        state.didUpdateLocations(location: locationTime178SecondAfter)
        
        wait(for: [expectation], timeout: 0.2)
    }

}

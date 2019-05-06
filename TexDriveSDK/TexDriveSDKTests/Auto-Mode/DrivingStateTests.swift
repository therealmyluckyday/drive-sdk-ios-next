//
//  DrivingStateTests.swift
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

class DrivingStateTests: XCTestCase {
    var disposeBag = DisposeBag()
    let context = StubAutoModeContextProtocol()
    
    func testStop() {
        let state = DrivingState(context: context, locationManager: LocationManager())
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DetectionOfStopState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.stop()
        wait(for: [expectation], timeout: 1)
    }
    /*
     Scenario: From Diving or Stopped state to WaitingScanTrigger state
     Given the automode in the Driving state
     When forceStop is called
     Then the state machine goes to the WaitingScanTrigger state
     Then the trip is closed
     */
    func testForceStop() {
        let state = DrivingState(context: context, locationManager: LocationManager())
        let expectation1 = XCTestExpectation(description: #function + "DetectionOfStopState")
        let expectation2 = XCTestExpectation(description: #function + "StandbyState")
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                switch state {
                case is DetectionOfStopState:
                    expectation1.fulfill()
                    break
                case is StandbyState:
                    expectation2.fulfill()
                    break
                default:
                    XCTAssert(false)
                }
            }
            }.disposed(by: disposeBag)
        state.forceStop()
        wait(for: [expectation1, expectation2], timeout: 1)
    }
    
    func testDisable() {
        let state = DrivingState(context: context, locationManager: LocationManager())
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
     Scenario: From Driving to Stopped state
     Given the automode in the Driving state
     When stop is maybe detected
     * TOTEST When a GPS point with speed lower than 10 km/h is received
     Then the state machine goes to the Stopped state
     But the trip is still running
     */
    
    func testLowSpeed() {
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DetectionOfStopState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        
        
        let state = DrivingState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        state.sensorState = .enable
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime21SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date().addingTimeInterval(21))
        state.didUpdateLocations(location: locationTime21SecondAfter)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDoNothing() {
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DetectionOfStopState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        
        
        let state = DrivingState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime21SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date().addingTimeInterval(21))
        state.didUpdateLocations(location: locationTime21SecondAfter)
        
        wait(for: [expectation], timeout: 0.2)
    }
    
    func testHighSpeed() {
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            expectation.fulfill()
            }.disposed(by: disposeBag)
        
        //Given the automode is in the ScanningActivity
        let state = DrivingState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        //When for at least 1 minute GPS points have a speed less than 20 km/h
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 11, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime118SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 21, timestamp: Date().addingTimeInterval(118))
        state.didUpdateLocations(location: locationTime118SecondAfter)
        //Then the state machine goes to WaitingScanTrigger state
        wait(for: [expectation], timeout: 1)
    }
    
    /*
     Scenario: From Diving or Stopped state to WaitingScanTrigger state
     Given the automode in the Stopped or Driving state
     When any GPS is received for longer than 4 minutes
     Then the state machine goes to the WaitingScanTrigger state
     Then the trip is closed
     */
    
    func testDrivingToDetectionOfStartStopCalled4minNoGPS() {
    }

}

//
//  DetectionOfStartStateTests.swift
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


class DetectionOfStartStateTests: XCTestCase {
    var disposeBag = DisposeBag()
    let context = StubAutoModeContextProtocol()
    
    func testStop() {
        let state = DetectionOfStartState(context: context, locationManager: LocationManager())
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
        let state = DetectionOfStartState(context: context, locationManager: LocationManager())
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
        let state = DetectionOfStartState(context: context, locationManager: LocationManager())
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
     Scenario: From DetectionOfStart to StandbyState state
     Given the automode is in the DetectionOfStart
     When for at least 1 minute GPS points have a speed less than 20 km/h
     Then the state machine goes to StandbyState state
 */
    func testLowSpeed() {
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is StandbyState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        
        //Given the automode is in the ScanningActivity
        let state = DetectionOfStartState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        state.sensorState = .enable
        //When for at least 1 minute GPS points have a speed less than 20 km/h
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)

        let date121SecondAfter = Date().addingTimeInterval(state.timeLowSpeedThreshold+1)
        let locationTime121SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp:date121SecondAfter)
        state.didUpdateLocations(location: locationTime121SecondAfter)
        
        let locationTime242SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: date121SecondAfter.addingTimeInterval(state.timeLowSpeedThreshold+1))
        state.didUpdateLocations(location: locationTime242SecondAfter)
        //Then the state machine goes to WaitingScanTrigger state
        wait(for: [expectation], timeout: 10)
    }
    
    /*
     Scenario: From DetectionOfStartState to DrivingState
     Given the automode is in the DetectionOfStartState
     When a GPS point with a speed higher than 20km/h is received
     Then the state machine goes to DrivingState
     */
    
    func testHighSpeed() {
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DrivingState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        
        //Given the automode is in the ScanningActivity
        let state = DetectionOfStartState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        state.sensorState = .enable
        //When for at least 1 minute GPS points have a speed less than 20 km/h
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime118SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 21, timestamp: Date().addingTimeInterval(118))
        state.didUpdateLocations(location: locationTime118SecondAfter)
        //Then the state machine goes to WaitingScanTrigger state
        wait(for: [expectation], timeout: 1)
    }
    
    func testHighSpeedDoNothing() {
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DrivingState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        
        //Given the automode is in the ScanningActivity
        let state = DetectionOfStartState(context: context, locationManager: LocationManager(), motionActivityManager: CMMotionActivityManager())
        //When for at least 1 minute GPS points have a speed less than 20 km/h
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime118SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 21, timestamp: Date().addingTimeInterval(118))
        state.didUpdateLocations(location: locationTime118SecondAfter)
        //Then the state machine goes to WaitingScanTrigger state
        wait(for: [expectation], timeout: 0.3)
    }
}

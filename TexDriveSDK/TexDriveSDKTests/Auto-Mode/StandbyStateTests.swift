//
//  StandbyStateTests.swift
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

class StandbyStateTests: XCTestCase {
    var disposeBag = DisposeBag()
    let context = StubAutoModeContextProtocol()
    
    func testStart() {
        let state = StandbyState(context: context)
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DetectionOfStartState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        state.start()
        wait(for: [expectation], timeout: 1)
    }
    
    func testDrive() {
        let state = StandbyState(context: context)
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
        let state = StandbyState(context: context)
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
     Scenario: From ServiceNotStarted to WaitingScanTrigger state callind enable
     Given the app embedding the SDK is running (at least in background)
     And the phone has not the airplane mode active
     When the ScanTrigger state is enabled
     Then the monitoring for a significant location change is activated
     */
    
    
    func testLowSpeed() {
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            expectation.fulfill()
            }.disposed(by: disposeBag)
        
        //Given the automode is in the ScanningActivity
        let state = StandbyState(context: context, locationManager: CLLocationManager(), motionActivityManager: CMMotionActivityManager())
        //When for at least 1 minute GPS points have a speed less than 20 km/h
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime121SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date().addingTimeInterval(121))
        state.didUpdateLocations(location: locationTime121SecondAfter)
        //Then the state machine goes to WaitingScanTrigger state
        wait(for: [expectation], timeout: 1)
    }
    
    /*
     Scenario: From Standby to DetectionOfStart
     Given the automode is in the ScanningActivity state
     When a GPS point with a speed higher than 10km/h is received
     Then the state machine goes to Detection of start state
     */
    
    func testHighSpeed() {
        let expectation = XCTestExpectation(description: #function)
        context.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is DetectionOfStartState)
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        
        //Given the automode is in the ScanningActivity
        let state = StandbyState(context: context, locationManager: CLLocationManager(), motionActivityManager: CMMotionActivityManager())
        //When for at least 1 minute GPS points have a speed less than 20 km/h
        let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 1, timestamp: Date())
        state.didUpdateLocations(location: location)
        
        let locationTime118SecondAfter = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 14, longitude: 15), altitude: 1000, horizontalAccuracy: 1, verticalAccuracy: 1, course: 1, speed: 11, timestamp: Date().addingTimeInterval(118))
        state.didUpdateLocations(location: locationTime118SecondAfter)
        //Then the state machine goes to WaitingScanTrigger state
        wait(for: [expectation], timeout: 1)
    }
}

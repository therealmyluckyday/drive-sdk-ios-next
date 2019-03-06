//
//  AutoModeGherkinTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 28/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK
@testable import RxSwift

class AutoModeGherkinTests: XCTestCase {
    var automode: AutoMode?
    var disposeBag: DisposeBag?
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        automode = AutoMode(locationManager: LocationManager())
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        disposeBag = nil
        automode?.disable()
    }
    /*
    Scenario: From ServiceNotStarted to WaitingScanTrigger state
    Given the app embedding the SDK is running (at least in background)
    And the phone has not the airplane mode active
    When the user/app activates the Automode service
    Then the state machine goes from Idle to ScanTrigger state
    * TOTEST IN StandbyState Then the monitoring for a significant location change is activated
     */
    func testDisabledToStandbyStateWhenEnabledCalled() {
        var isCalled = false
    automode?.rxState.asObservable().observeOn(MainScheduler.instance).subscribe({ (event) in
        isCalled = true
            if let state = event.element {
                print(state)
                switch state {
                case is StandbyState:
                    XCTAssert(true)
                    break
                default:
                    XCTAssert(false)
                }
            } else {
                XCTAssert(false)
            }
        }).disposed(by: disposeBag!)
        automode?.enable()
        XCTAssert(isCalled)
    }

    /*
    Scenario: From WaitingScanTrigger to scanningActivity state
    Given the automode is in the waitingScanTrigger state
    When a significantLocationChange is received
    Then the state machine goes to the ScanningActivity state
    * TOTEST IN DetectionOfStartState Then the location manager continues listening for GPS points
    But the trip is not started yet*/
    func testStandByToDetectionOfStartStateStartCalled() {
        let expectation = XCTestExpectation(description: #function)
        let context = StubAutoModeContextProtocol ()
        let state = StandbyState(context: context, locationManager: LocationManager())
        context.state = state
        context.rxState.asObservable().observeOn(MainScheduler.instance).subscribe({ (event) in
            XCTAssertNotNil(event.element)
            if let state = event.element {
                print(state)
                XCTAssertTrue(state is DetectionOfStartState)
            }
            expectation.fulfill()
        }).disposed(by: disposeBag!)
        state.start()
        wait(for: [expectation], timeout: 1 )
    }
    
    /*
    Scenario: From ScanningActivity to WaitingScanTrigger state
    Given the automode is in the ScanningActivity
     * TOTEST in DetectionOfStart When for at least 1 minute GPS points have a speed less than 20 km/h
     When stop called in DetectionOfStartState
    Then the state machine goes to WaitingScanTrigger state*/
    func testDetectionOfStartStateToStandByStopCalled() {
        let expectation = self.expectation(description: "testDetectionOfStartStateToStandByStopCalled")
        let stubAutoMode = StubAutoModeContextProtocol ()
        let state = DetectionOfStartState(context: stubAutoMode, locationManager: LocationManager())
        stubAutoMode.state = state
        stubAutoMode.rxState.asObservable().observeOn(MainScheduler.instance).subscribe({(event) in
            if let state = event.element {
                print(state)
                switch state {
                case is StandbyState:
                    expectation.fulfill()
                    break
                default:
                    XCTAssert(false)
                }
            } else {
                XCTAssert(false)
            }
        }).disposed(by: disposeBag!)
        state.stop()
        wait(for: [expectation], timeout: 1)
    }
    
    /*
    Scenario: From SanningActivity to Driving state
    Given the automode is in the ScanningActivity state
    When driving is detected
    * TOTEST When a GPS point with a speed higher than 20km/h is received
    Then the state machine goes to diving state
    Then a new trip is started
 */
    func testDetectionOfStartToDrivingDriveCalled() {
        let expectation = self.expectation(description: "testDetectionOfStartToDrivingDriveCalled")
        let stubAutoMode = StubAutoModeContextProtocol ()
        let state = DetectionOfStartState(context: stubAutoMode, locationManager: LocationManager())
        stubAutoMode.state = state
        stubAutoMode.rxState.asObservable().observeOn(MainScheduler.instance).subscribe({(event) in
            if let state = event.element {
                print(state)
                switch state {
                case is DrivingState:
                    expectation.fulfill()
                    break
                default:
                    XCTAssert(false)
                }
            } else {
                XCTAssert(false)
            }
        }).disposed(by: disposeBag!)
        state.drive()
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
    func testDrivingToDetectionOfStopStopCalled() {
        let expectation = self.expectation(description: "testDetectionOfStartToDrivingDriveCalled")
        let stubAutoMode = StubAutoModeContextProtocol ()
        let state = DrivingState(context: stubAutoMode, locationManager: LocationManager())
        stubAutoMode.state = state
        stubAutoMode.rxState.asObservable().observeOn(MainScheduler.instance).subscribe({(event) in
            if let state = event.element {
                print(state)
                switch state {
                case is DetectionOfStopState:
                    expectation.fulfill()
                    break
                default:
                    XCTAssert(false)
                }
            } else {
                XCTAssert(false)
            }
        }).disposed(by: disposeBag!)
        state.stop()
        wait(for: [expectation], timeout: 1)
    }
    
    /*
    Scenario: From Stopped to Driving state
    Given the automode in the Stopped state for less than 3 minutes
    When the automotive move
    * TOTEST When a GPS point with a speed higher than 10 km/h is received
    Then the state machine goes to the Driving state
 */
    func testDetectionOfStopToDrivingOfDriveCalled() {
        let expectation = self.expectation(description: "testDetectionOfStopToDrivingOfDriveCalled")
        let stubAutoMode = StubAutoModeContextProtocol ()
        let state = DetectionOfStopState(context: stubAutoMode, locationManager: LocationManager())
        stubAutoMode.state = state
        stubAutoMode.rxState.asObservable().observeOn(MainScheduler.instance).subscribe({(event) in
            if let state = event.element {
                print(state)
                switch state {
                case is DrivingState:
                    expectation.fulfill()
                    break
                default:
                    XCTAssert(false)
                }
            } else {
                XCTAssert(false)
            }
        }).disposed(by: disposeBag!)
        state.drive()
        wait(for: [expectation], timeout: 1)
    }
    
    
    /*
    Scenario: From Stopped to WaitingScanTrigger state
    Given the automode in the Stopped state
    * TOTEST When any GPS with speed higher than 10 km/h is received for 3 minutes
     When stop is detected
    Then the state machine goes to the WaitingScanTrigger state
    Then the trip is closed
 */
    func testDetectionOfStopToDetectionOfStartStopCalled() {
        let expectation = self.expectation(description: #function)
        let stubAutoMode = StubAutoModeContextProtocol ()
        let state = DetectionOfStopState(context: stubAutoMode, locationManager: LocationManager())
        stubAutoMode.state = state
        stubAutoMode.rxState.asObservable().observeOn(MainScheduler.instance).subscribe({(event) in
            if let state = event.element {
                print(state)
                switch state {
                case is StandbyState:
                    expectation.fulfill()
                    break
                default:
                    XCTAssert(false)
                }
            } else {
                XCTAssert(false)
            }
        }).disposed(by: disposeBag!)
        state.stop()
        wait(for: [expectation], timeout: 1)
    }
}

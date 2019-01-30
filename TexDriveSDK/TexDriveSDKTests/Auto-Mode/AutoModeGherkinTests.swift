//
//  AutoModeGherkinTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 28/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class AutoModeGherkinTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    /*
    Scenario: From ServiceNotStarted to WaitingScanTrigger state
    Given the app embedding the SDK is running (at least in background)
    And the phone has not the airplane mode active
    When the user/app activates the Automode service
    Then the state machine goes from Idle to ScanTrigger state
    Then the monitoring for a significant location change is activated*/
    func testDisabledToStandbyStateWhenEnabledCalled() {

    }

    /*
    Scenario: From WaitingScanTrigger to scanningActivity state
    Given the automode is in the waitingScanTrigger state
    When a significantLocationChange is received
    Then the state machine goes to the ScanningActivity state
    Then the location manager continues listening for GPS points
    But the trip is not started yet*/
    func testStandByToDetectionOfStartStateStartCalled() {
    }
    
    /*
    Scenario: From ScanningActivity to WaitingScanTrigger state
    Given the automode is in the ScanningActivity
    When for at least 1 minute GPS points have a speed less than 20 km/h
    Then the state machine goes to WaitingScanTrigger state*/
    func testDetectionOfStartStateToStandByStopCalled() {
    }
    
    /*
    Scenario: From SanningActivity to Driving state
    Given the automode is in the ScanningActivity state
    When a GPS point with a speed higher than 20km/h is received
    Then the state machine goes to diving state
    Then a new trip is started
 */
    func testDetectionOfStartToDrivingDriveCalled() {
    }
    
    /*
    Scenario: From Driving to Stopped state
    Given the automode in the Driving state
    When a GPS point with speed lower than 10 km/h is received
    Then the state machine goes to the Stopped state
    But the trip is still running
 */
    func testDrivingToDetectionOfStopStopCalled() {
    }
    
    /*
    Scenario: From Stopped to Driving state
    Given the automode in the Stopped state for less than 3 minutes
    When a GPS point with a speed higher than 10 km/h is received
    Then the state machine goes to the Driving state
 */
    func testDetectionOfStopToDrivingOfDriveCalled() {
    }
    
    
    /*
    Scenario: From Stopped to WaitingScanTrigger state
    Given the automode in the Stopped state
    When any GPS with speed higher than 10 km/h is received for 3 minutes
    Then the state machine goes to the WaitingScanTrigger state
    Then the trip is closed
 */
    func testDetectionOfStopToDetectionOfStartStopCalled() {
    }
   
    /*
    Scenario: From Diving or Stopped state to WaitingScanTrigger state
    Given the automode in the Stopped or Driving state
    When any GPS is received for longer than 4 minutes
    Then the state machine goes to the WaitingScanTrigger state
    Then the trip is closed
 */
    func testDrivingOfStopToDetectionOfStartStopCalled4minNoGPS() {
    }
    
    func testDrivingToDetectionOfStartStopCalled4minNoGPS() {
    }

}

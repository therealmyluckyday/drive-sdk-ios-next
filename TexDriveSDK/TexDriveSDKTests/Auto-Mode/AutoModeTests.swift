//
//  AutoModeTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 20/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK
@testable import RxSwift

class AutoModeTests: XCTestCase {
    var disposeBag = DisposeBag()
    
    func testInit() {
        let autoMode = AutoMode(locationManager: LocationManager())
        XCTAssertNil(autoMode.state)
        XCTAssertEqual(autoMode.status, .ServiceNotStarted)
    }

    func testEnable() {
        let autoMode = AutoMode(locationManager: LocationManager())
        
        let expectation = XCTestExpectation(description: #function)
        autoMode.rxState.asObserver().observe(on: MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                if state is StandbyState {
                    expectation.fulfill()
                }
            }
            }.disposed(by: disposeBag)
        autoMode.enable()
        wait(for: [expectation], timeout: 1)
    }

    func testDisable() {
        let autoMode = AutoMode(locationManager: LocationManager())
        autoMode.disable()
        XCTAssertNil(autoMode.state)
    }
    
    func testStatusStandbyState() {
        let locationManager = LocationManager()
        let autoMode = AutoMode(locationManager: locationManager)
        autoMode.state = StandbyState(context: autoMode, locationManager: locationManager)
        XCTAssertEqual(autoMode.status, .WaitingScanTrigger)
    }
    
    func testStatusDetectionOfStartState() {
        let locationManager = LocationManager()
        let autoMode = AutoMode(locationManager: locationManager)
        autoMode.state = DetectionOfStartState(context: autoMode, locationManager: locationManager)
        XCTAssertEqual(autoMode.status, .ScanningActivity)
    }
    func testStatusDrivingState() {
        let locationManager = LocationManager()
        let autoMode = AutoMode(locationManager: locationManager)
        autoMode.state = DrivingState(context: autoMode, locationManager: locationManager)
        XCTAssertEqual(autoMode.status, .Driving)
    }
    
    func testStatusDetectionOfStopState() {
        let locationManager = LocationManager()
        let autoMode = AutoMode(locationManager: locationManager)
        autoMode.state = DetectionOfStopState(context: autoMode, locationManager: locationManager)
        XCTAssertEqual(autoMode.status, .Stopped)
    }
    
    func testStatusDisableState() {
        let locationManager = LocationManager()
        let autoMode = AutoMode(locationManager: locationManager)
        autoMode.state = DisabledState(context: autoMode)
        XCTAssertEqual(autoMode.status, .ServiceNotStarted)
    }
}

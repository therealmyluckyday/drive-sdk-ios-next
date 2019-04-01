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
    }

    func testEnable() {
        let autoMode = AutoMode(locationManager: LocationManager())
        
        let expectation = XCTestExpectation(description: #function)
        autoMode.rxState.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let state = event.element {
                XCTAssert(state is StandbyState)
                expectation.fulfill()
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
}

//
//  AutoModeTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 20/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class AutoModeTests: XCTestCase {
    
    func testInit() {
        let autoMode = AutoMode()
        XCTAssertNil(autoMode.state)
    }

    func testEnable() {
        let autoMode = AutoMode()
        autoMode.enable()
        XCTAssertNotNil(autoMode.state)
        XCTAssert(autoMode.state! is StandbyState)
    }

    func testDisable() {
        let autoMode = AutoMode()
        autoMode.disable()
        XCTAssertNil(autoMode.state)
    }
    
    func testStop() {
        let autoMode = AutoMode()
        autoMode.enable()
        autoMode.stop()
        XCTAssertNotNil(autoMode.state)
        XCTAssertFalse(autoMode.state! is DetectionOfStartState)
    }
}

//
//  APIErrorTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 07/03/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class APIErrorTests: XCTestCase {
    func testInit() {
        let message = "SuperToto"
        let statusCode = 1001
        let error = APIError(message: message, statusCode: statusCode)
        XCTAssertEqual(error.message, message)
        XCTAssertEqual(error.statusCode, statusCode)
    }
    
    func testLocalizedDescription() {
        let message = "SuperToto"
        let statusCode = 1001
        let error = APIError(message: message, statusCode: statusCode)
        XCTAssertEqual(error.localizedDescription, "Error on request \(statusCode) message: \(message)")
    }
}

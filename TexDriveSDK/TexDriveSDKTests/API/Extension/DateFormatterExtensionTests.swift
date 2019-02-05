//
//  DateFormatterExtensionTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class DateFormatterExtensionTests: XCTestCase {
    // MARK: static func formattedTimeZone () -> String
    func testFormattedTimeZone() {
        let result = DateFormatter.formattedTimeZone()
        XCTAssertEqual(result, "+0100")
    }
}

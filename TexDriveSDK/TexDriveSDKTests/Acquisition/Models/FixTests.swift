//
//  FixTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

struct FixTest: Fix {
    var description = "descriptionFixTest"
    
    var timestamp: TimeInterval = 999 //location.timestamp.timeIntervalSince1970 * 1000
    func serialize() -> [String: Any] {
        return [String: Any]()
    }
}

class FixTests: XCTestCase {
    // MARK: func serializeTimestamp() -> (String, Int)
    func testSerializeTimestamp() {
        let fix = FixTest()
        let (key, value) = fix.serializeTimestamp()
        
        XCTAssertEqual(value, 999*1000)
        XCTAssertEqual(key, "timestamp")
    }
}

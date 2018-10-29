//
//  DoubleExtensionTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class DoubleRoundedDoubleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: RoundedDouble
    // MARK: func rounded(toDecimalPlaces n: Int) -> Double
    func testRounded() {
        let roundedUp = 9.9999999999
        let roundedDown = 9.9991111111
        
        let resultUp = roundedUp.rounded(toDecimalPlaces: 6)
        let resultDown = roundedDown.rounded(toDecimalPlaces: 6)
        
        print(resultUp)
        print(resultDown)
        XCTAssertEqual(resultUp, 10)
        XCTAssertEqual(resultDown, 9.999111)
    }
    
}

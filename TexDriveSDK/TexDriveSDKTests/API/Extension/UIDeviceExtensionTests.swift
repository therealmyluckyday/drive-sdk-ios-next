//
//  UIDeviceExtensionTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class UIDeviceExtensionTests: XCTestCase {

    // MARK: func os() -> String
    func testOs() {
        let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        
        let result = UIDevice.current.os()
        
        XCTAssertEqual(result, os)
    }
    
}

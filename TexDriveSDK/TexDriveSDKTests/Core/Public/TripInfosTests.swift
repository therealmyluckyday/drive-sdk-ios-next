//
//  TripInfosTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 12/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class TripInfosTests: XCTestCase {
    
    // MARK: static func serializeWithGeneralInformation(dictionary: [String: Any], appId: String) -> [String: Any]
    func testSerializeWithGeneralInformation() {
        let dictionary = ["toto": 1984]
        let appId = "AXAAppId"
        let tripInfos =  TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction)
        let result = tripInfos.serializeWithGeneralInformation(dictionary: dictionary)
        
        let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let sdkVersion = "3.0.0"
        let firstVia = "TEX_iOS_SDK/\(os)/\(sdkVersion)"
        XCTAssertEqual(result["uid"] as! String, UIDevice.current.identifierForVendor!.uuidString)
        XCTAssertNotNil(result["timezone"] as? String)
        XCTAssertEqual(result["os"] as! String, UIDevice.current.os())
        XCTAssertEqual(result["model"] as! String, UIDevice.current.hardwareString())
        XCTAssertEqual(result["version"] as! String, sdkVersion)
        XCTAssertEqual(result["app_name"] as! String, appId)
        XCTAssertEqual(result["via"] as! [String], [firstVia])
    }
    
}

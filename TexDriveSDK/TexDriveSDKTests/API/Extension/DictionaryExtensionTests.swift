//
//  DictionaryExtensionTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class DictionaryExtensionTests: XCTestCase {
    // MARK: static func serializeWithGeneralInformation(dictionary: [String: Any], appId: String) -> [String: Any]
    func testSerializeWithGeneralInformation() {
        let dictionary = ["toto": 1984]
        let appId = "AXAAppId"
        
        let result = Dictionary<String, Any>.serializeWithGeneralInformation(dictionary: dictionary, appId: appId, user: User.Anonymous)
        
        let os = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        let sdkVersion = Bundle(for: APITrip.self).infoDictionary!["CFBundleShortVersionString"] as! String
        let firstVia = "TEX_iOS_SDK/\(os)/\(sdkVersion)"
        XCTAssertEqual(result["uid"] as! String, UIDevice.current.identifierForVendor!.uuidString)
        XCTAssertEqual(result["timezone"] as! String, "+0100")
        XCTAssertEqual(result["os"] as! String, UIDevice.current.os())
        XCTAssertEqual(result["model"] as! String, UIDevice.current.hardwareString())
        XCTAssertEqual(result["version"] as! String, sdkVersion)
        XCTAssertEqual(result["app_name"] as! String, appId)
        XCTAssertEqual(result["via"] as! [String], [firstVia])
    }
}

//
//  APIConfigurationTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class APIConfigurationTests: XCTestCase {
    
    // MARK: Domain
    func testDomainName() {
        XCTAssertEqual(Platform.Integration.rawValue, "gw-int.tex.dil.services")
        XCTAssertEqual(Platform.Preproduction.rawValue, "gw-preprod.tex.dil.services")
        XCTAssertEqual(Platform.Production.rawValue, "gw.tex.dil.services")
    }
    
    // MARK: func baseUrl() -> String
    func testBaseUrlIntegration() {
        let domain = Platform.Integration
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw-int.tex.dil.services"+"/v2.0")
    }
    func testBaseUrlPreprod() {
        let domain = Platform.Preproduction
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw-preprod.tex.dil.services"+"/v2.0")
    }
    func testBaseUrlProd() {
        let domain = Platform.Production
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw.tex.dil.services"+"/v2.0")
    }
    
    // MARK: func httpHeaders() -> [String: Any]
    func testHTTPHeaders() {
        let domain = Platform.Production
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain)
        
        let result = config.httpHeaders()
        
        XCTAssertEqual(result["Content-Encoding"] as! String, "gzip")
        XCTAssertEqual(result["X-AppKey"] as! String, "APPxID")
    }
}

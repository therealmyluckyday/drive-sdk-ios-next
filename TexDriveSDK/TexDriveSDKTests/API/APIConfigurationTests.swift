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
        XCTAssertEqual(Platform.Testing.generateUrl(isAPIV2: false), "gw-uat.tex.dil.services")
        XCTAssertEqual(Platform.Integration.generateUrl(isAPIV2: false), "gw-int.tex.dil.services")
        XCTAssertEqual(Platform.Preproduction.generateUrl(isAPIV2: false), "gw-preprod.tex.dil.services")
        XCTAssertEqual(Platform.Production.generateUrl(isAPIV2: false), "gw.tex.dil.services")
    }
    
    func testDomainNameAPIV2() {
        XCTAssertEqual(Platform.Testing.generateUrl(isAPIV2: true), "mobile-sink.youdrive-dev.next.dil.services")
        XCTAssertEqual(Platform.Integration.generateUrl(isAPIV2: true), "mobile-sink.youdrive-uat.next.dil.services")
        XCTAssertEqual(Platform.Preproduction.generateUrl(isAPIV2: true), "mobile-sink.youdrive-pp.next.dil.services")
        XCTAssertEqual(Platform.Production.generateUrl(isAPIV2: true), "mobile-sink.youdrive.next.dil.services")
    }

    // MARK: func baseUrl() -> String
    func testBaseUrlIntegration() {
        let domain = Platform.Integration
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain, isAPIV2: false)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw-int.tex.dil.services"+"/v2.0")
    }
    func testBaseUrlPreprod() {
        let domain = Platform.Preproduction
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain, isAPIV2: false)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw-preprod.tex.dil.services"+"/v2.0")
    }
    func testBaseUrlProd() {
        let domain = Platform.Production
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain, isAPIV2: false)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw.tex.dil.services"+"/v2.0")
    }
    
    // MARK: func httpHeaders() -> [String: Any]
    func testHTTPHeaders() {
        let domain = Platform.Production
        let appId = "APPxID"
        let config = TripInfos(appId: appId, user: TexUser.Authentified("Erwan-ios12"), domain: domain, isAPIV2: false)
        
        let result = config.httpHeaders()
        
        XCTAssertEqual(result["Content-Encoding"] as! String, "gzip")
        XCTAssertEqual(result["X-AppKey"] as! String, "APPxID")
    }
}

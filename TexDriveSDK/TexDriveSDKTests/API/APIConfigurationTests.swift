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
        XCTAssertEqual(Domain.Integration.rawValue, "gw-int.tex.dil.services")
        XCTAssertEqual(Domain.Preproduction.rawValue, "gw-preprod.tex.dil.services")
        XCTAssertEqual(Domain.Production.rawValue, "gw.tex.dil.services")
    }
    
    // MARK: func baseUrl() -> String
    func testBaseUrlIntegration() {
        let domain = Domain.Integration
        let appId = "APPxID"
        let config = APIConfiguration(appId: appId, domain: domain)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw-int.tex.dil.services"+"/v2.0")
    }
    func testBaseUrlPreprod() {
        let domain = Domain.Preproduction
        let appId = "APPxID"
        let config = APIConfiguration(appId: appId, domain: domain)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw-preprod.tex.dil.services"+"/v2.0")
    }
    func testBaseUrlProd() {
        let domain = Domain.Production
        let appId = "APPxID"
        let config = APIConfiguration(appId: appId, domain: domain)
        
        let result = config.baseUrl()
        
        XCTAssertEqual(result, "https://"+"gw.tex.dil.services"+"/v2.0")
    }
    
    // MARK: func httpHeaders() -> [String: Any]
    func testHTTPHeaders() {
        let domain = Domain.Production
        let appId = "APPxID"
        let config = APIConfiguration(appId: appId, domain: domain)
        
        let result = config.httpHeaders()
        
        XCTAssertEqual(result["Content-Encoding"] as! String, "gzip")
        XCTAssertEqual(result["X-AppKey"] as! String, "APPxID")
    }
}

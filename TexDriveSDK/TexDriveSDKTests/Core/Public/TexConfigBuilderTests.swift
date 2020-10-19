//
//  TexConfigBuilderTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 17/04/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest
import CoreLocation
@testable import TexDriveSDK

class TexConfigBuilderTests: XCTestCase {
    
    // MARK: - public init(appId: String, texUser: User)
    func testInit() {
        let appId = "APPTEST"
        let user = TexUser.Authentified("TOTO")
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        XCTAssertEqual(appId, builder.config.tripInfos.appId)
        XCTAssertEqual(user, builder.config.tripInfos.user)
        XCTAssertEqual(appId, builder._config.tripInfos.appId)
        XCTAssertEqual(user, builder._config.tripInfos.user)
        XCTAssertEqual(appId, builder.appId)
        XCTAssertEqual(user, builder.texUser)
        
        XCTAssertEqual(builder.config.locale, builder._config.locale)
        XCTAssertEqual(builder.config.tripInfos, builder._config.tripInfos)
        XCTAssertEqual(builder.config.domain, builder._config.domain)
    }
    
    // MARK: - public func enableTripRecorder() throws
    func testEnableTripRecorder() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockCLLocationManager = MockCLLocationManager()
        let appId = "APPTEST"
        let user = TexUser.Authentified("TOTO")
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        do {
            try builder.enableTripRecorder(locationManager: locationManager)
            XCTAssertEqual(builder._config.tripRecorderFeatures.count, 1)
            XCTAssertNotNil(builder._config.tripRecorderFeatures.first)
            
            switch builder._config.tripRecorderFeatures.first! {
            case .Location(let locationManager):
                XCTAssertEqual(locationManager.trackerLocationSensor.clLocationManager, mockCLLocationManager)
            default:
                XCTAssert(false)
            }
        }  catch ConfigurationError.LocationNotDetermined( _) {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
    }
    
    // MARK: - public func select(platform: Domain) -> TexConfigBuilder
    func testSelectPlatformProd() {
        let appId = "APPTEST"
        let user = TexUser.Authentified("TOTO")
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        
        builder.select(platform: Platform.Integration, isAPIV2: false)
        builder.select(platform: Platform.Production, isAPIV2: false)
        
        XCTAssertEqual(builder._config.domain, Platform.Production)
    }
    func testSelectPlatformPreProd() {
        let appId = "APPTEST"
        let user = TexUser.Authentified("TOTO")
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        
        builder.select(platform: Platform.Integration, isAPIV2: false)
        builder.select(platform: Platform.Preproduction, isAPIV2: false)
        
        XCTAssertEqual(builder._config.domain, Platform.Preproduction)
    }
    func testSelectPlatformIntegration() {
        let appId = "APPTEST"
        let user = TexUser.Authentified("TOTO")
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        
        builder.select(platform: Platform.Production, isAPIV2: false)
        builder.select(platform: Platform.Integration, isAPIV2: false)
        
        XCTAssertEqual(builder._config.domain, Platform.Integration)
    }
    
    // MARK: - public func build() -> TexConfig
    func testBuild() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockCLLocationManager = MockCLLocationManager()
        let appId = "APPTESTA"
        let user = TexUser.Authentified("TOTOA")
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        let expectation = XCTestExpectation(description: #function)
        builder.select(platform: Platform.Integration, isAPIV2: false)
        let locationManager = LocationManager(locationManager: mockCLLocationManager)
        do {
            try builder.enableTripRecorder(locationManager: locationManager)

            let texconfig = builder.build()
            expectation.fulfill()
            
            XCTAssertNotNil(texconfig.tripRecorderFeatures.first)
            
            if let feature = texconfig.tripRecorderFeatures.first {
                switch feature {
                case .Location(let locationManager):
                    XCTAssertEqual(locationManager.trackerLocationSensor.clLocationManager, mockCLLocationManager)
                default:
                    XCTAssert(false)
                }
            }
            
            XCTAssertEqual(texconfig.tripInfos.appId, builder._config.tripInfos.appId)
            XCTAssertEqual(texconfig.tripInfos.user, builder._config.tripInfos.user)

            
            XCTAssertEqual(builder.config.locale, texconfig.locale)
            XCTAssertEqual(builder.config.tripInfos, texconfig.tripInfos)
            XCTAssertEqual(builder.config.domain, texconfig.domain)
            
            XCTAssertEqual(texconfig.domain, Platform.Integration)
        }  catch ConfigurationError.LocationNotDetermined( _) {
            XCTAssert(false)
        } catch {
            XCTAssert(false)
        }
        wait(for: [expectation], timeout: 0.01)
    }
}


//
//  ConfigTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class ConfigTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_LocationFeature_can_not_activated() {
        let appId = "MyAppId"
        let locale = Locale.current
        let user = User.Anonymous
        let mode = Mode.manual
        let mockLocationManager = MockLocationManagerNotDetermined()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: locale, currentUser: user, currentMode: mode, currentTripRecorderFeatures: features)
            XCTAssertNil(configuration)
        } catch ConfigurationError.LocationNotDetermined( _) {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testInit_BAtteryFeature_can_activated() {
        let appId = "MyAppId"
        let locale = Locale.current
        let user = User.Anonymous
        let mode = Mode.manual
        let feature = TripRecorderFeature.Battery(UIDevice.current)
        let features = [feature]
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: locale, currentUser: user, currentMode: mode, currentTripRecorderFeatures: features)
            XCTAssertNotNil(configuration)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testInit_General() {
        
    }
    
}

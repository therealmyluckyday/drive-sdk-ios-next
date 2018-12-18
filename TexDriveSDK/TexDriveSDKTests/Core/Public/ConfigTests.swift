//
//  ConfigTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CoreLocation
@testable import TexDriveSDK
import RxSwift

class MockConfiguration : ConfigurationProtocol {
    var tripInfos: TripInfos
    
    var rxScheduler: SerialDispatchQueueScheduler = MainScheduler.instance
    
    var rxLog = PublishSubject<LogMessage>()
    
    func log(regex: NSRegularExpression, logType: LogType) {
        
    }
    
    var tripRecorderFeatures: [TripRecorderFeature]
    let mockApiSessionManager = APISessionManagerMock()
    
    init(features: [TripRecorderFeature]) {
        tripRecorderFeatures = features
        tripInfos = TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction)
    }
    
    func generateAPISessionManager() -> APISessionManagerProtocol {
        return mockApiSessionManager
    }
}

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
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.notDetermined
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: locale, currentUser: user, currentTripRecorderFeatures: features)
            XCTAssertNil(configuration)
        } catch ConfigurationError.LocationNotDetermined( _) {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testInit_BatteryFeature_can_activated() {
        let appId = "MyAppId"
        let locale = Locale.current
        let user = User.Anonymous
        let feature = TripRecorderFeature.Battery(UIDevice.current)
        let features = [feature]
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: locale, currentUser: user, currentTripRecorderFeatures: features)
            XCTAssertNotNil(configuration)
        } catch {
            XCTAssert(false)
        }
    }
    
    // MARK: func generateAPISessionManager() -> APISessionManagerProtocol
    func testgenerateAPISessionManager() {
        let appId = "MyAppId"
        let locale = Locale.current
        let user = User.Anonymous
        let feature = TripRecorderFeature.Battery(UIDevice.current)
        let features = [feature]
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: locale, currentUser: user, currentTripRecorderFeatures: features)
            XCTAssertNotNil(configuration?.generateAPISessionManager() as? APISessionManager)
        } catch {
            XCTAssert(false)
        }

    }
    
}

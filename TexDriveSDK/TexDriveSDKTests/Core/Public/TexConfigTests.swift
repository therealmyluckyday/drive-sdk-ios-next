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
    var locale: Locale = Locale.current
    
    var tripInfos: TripInfos
    
    var rxScheduler: SerialDispatchQueueScheduler = MainScheduler.instance
    
    var rxLog = PublishSubject<LogMessage>()
    
    func log(regex: NSRegularExpression, logType: LogType) {
        
    }
    
    var tripRecorderFeatures: [TripRecorderFeature]

    
    init(features: [TripRecorderFeature]) {
        tripRecorderFeatures = features
        tripInfos = TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction)
    }
}

class TexConfigTests: XCTestCase {
    
    // MARK: - func select(domain: Domain)
    func testSelectDomainProduction() {
        let appId = "MyAppId"
        let user = TexUser.Anonymous
        let configuration = TexConfig(applicationId: appId, currentUser: user)
        configuration.select(domain: Platform.Production)
        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration.tripInfos.domain, Platform.Production)
    }
    func testSelectDomainPreProduction() {
        let appId = "MyAppId"
        let user = TexUser.Anonymous
        let configuration = TexConfig(applicationId: appId, currentUser: user)
        configuration.select(domain: Platform.Preproduction)
        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration.tripInfos.domain, Platform.Preproduction)
    }
    func testSelectDomainIntegration() {
        let appId = "MyAppId"
        let user = TexUser.Anonymous
        let configuration = TexConfig(applicationId: appId, currentUser: user)
        configuration.select(domain: Platform.Integration)
        XCTAssertNotNil(configuration)
        XCTAssertEqual(configuration.tripInfos.domain, Platform.Integration)
    }
    
    // MARK: - static func activable(features: [TripRecorderFeature]) throws
    
    func testActivableBattery() {
        let feature = TripRecorderFeature.Battery(UIDevice.current)
        let features = [feature]
        do {
            try TexConfig.activable(features: features)
        } catch {
            XCTAssert(false)
        }
    }
    
    func testActivableLocationFeature_can_not_activated() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.notDetermined
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(MockCLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor: autoModeLocationSensor, locationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        do {
            try TexConfig.activable(features: features)
            XCTAssert(false)
        } catch ConfigurationError.LocationNotDetermined( _) {
            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
}

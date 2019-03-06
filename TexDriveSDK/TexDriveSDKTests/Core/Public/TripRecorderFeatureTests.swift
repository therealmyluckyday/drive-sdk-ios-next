//
//  TripRecorderFeatureTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CallKit
import CoreLocation
@testable import TexDriveSDK

class TripRecorderFeatureTests: XCTestCase {
    func testcanActivate_Battery() {
        let feature = TripRecorderFeature.Battery(UIDevice.current)
        
        XCTAssert(feature.canActivate())
    }
    
    func testcanActivate_PhoneCall() {
        let feature = TripRecorderFeature.PhoneCall(CXCallObserver())
        
        XCTAssert(feature.canActivate())
    }
    
    func testCanActivateLocationReturnTrue() {
        let mockLocationManager = LocationManager(locationManager: MockCLLocationManager())
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let feature = TripRecorderFeature.Location(mockLocationManager)
        
        XCTAssert(feature.canActivate())
    }
    
    func testCanActivateLocationReturnFalseWhenAuthorizationStatusDenied() {
        let mockLocationManager = LocationManager(locationManager: MockCLLocationManager())
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.denied
        let feature = TripRecorderFeature.Location(mockLocationManager)
        
        XCTAssert(feature.canActivate())
    }
    func testCanActivateLocationWhenAuthorizationStatusNotDetermined() {
        let mockLocationManager = LocationManager(locationManager: MockCLLocationManager())
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.notDetermined
        let feature = TripRecorderFeature.Location(mockLocationManager)
        XCTAssertFalse(feature.canActivate())
    }
    func testCanActivateLocationWhenAuthorizationStatusRestricted() {
        let mockLocationManager = LocationManager(locationManager: MockCLLocationManager())
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.restricted
        let feature = TripRecorderFeature.Location(mockLocationManager)

        XCTAssert(feature.canActivate())
    }
    func testCanActivateLocationAuthorizationStatusAuthorizedWhenInUse() {
        let mockLocationManager = LocationManager(locationManager: MockCLLocationManager())
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedWhenInUse
        let feature = TripRecorderFeature.Location(mockLocationManager)

        XCTAssert(feature.canActivate())
    }
}

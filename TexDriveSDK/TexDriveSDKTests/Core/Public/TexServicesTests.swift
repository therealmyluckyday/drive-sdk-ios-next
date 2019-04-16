//
//  ServiceTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CoreLocation
@testable import TexDriveSDK

class TexServicesTests: XCTestCase {
    func testInit() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = LocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = TexServices.service(configuration: configuration)
        
        XCTAssertEqual(service.configuration!.tripRecorderFeatures.count, configuration.tripRecorderFeatures.count)
    }
    
    func testService() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = LocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = TexServices.service(configuration: configuration)
        
        XCTAssertEqual(service.configuration!.tripRecorderFeatures.count, configuration.tripRecorderFeatures.count)
    }
}

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
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = TexServices(configuration: configuration)
        
        XCTAssertEqual(service.configuration.tripRecorderFeatures.count, configuration.tripRecorderFeatures.count)
    }
    
    func testService() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = TexServices.service(withConfiguration: configuration)
        
        XCTAssertEqual(service.configuration.tripRecorderFeatures.count, configuration.tripRecorderFeatures.count)
    }
    
    // MARK: - func getscoreRetriever() -> (scoreRetriever)
    func testGetscoreRetriever() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let service = TexServices.service(withConfiguration: configuration)
        
        let _ = service.getscoreRetriever()
    }
}

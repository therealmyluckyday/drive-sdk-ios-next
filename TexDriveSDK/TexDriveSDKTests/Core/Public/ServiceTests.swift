//
//  ServiceTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class ServiceTests: XCTestCase {
    func testInit() {
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = Service(configuration: configuration)
        
        XCTAssertEqual(service.config.tripRecorderFeatures.count, configuration.tripRecorderFeatures.count)
    }
    
    func testService() {
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = Service.service(withConfiguration: configuration)
        
        XCTAssertEqual(service.config.tripRecorderFeatures.count, configuration.tripRecorderFeatures.count)
    }
}

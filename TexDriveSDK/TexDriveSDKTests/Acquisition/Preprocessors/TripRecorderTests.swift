//
//  TripRecorderTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation
@testable import TexDriveSDK



class MockConfiguration : ConfigurationProtocol {
    var rx_log = PublishSubject<LogDetail>()
    
    func log(regex: NSRegularExpression, logType: LogType) {
        
    }
    
    var tripRecorderFeatures: [TripRecorderFeature]
    let mockApiSessionManager = APISessionManagerMock()
    
    init(features: [TripRecorderFeature]) {
        tripRecorderFeatures = features
    }
    
    func generateAPISessionManager() -> APISessionManagerProtocol {
        return mockApiSessionManager
    }
}


class TripRecorderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testInit_LocationFeature() {
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let tripRecorder = TripRecorder(config: configuration)
        
        var locations = [CLLocation]()
        for i in 0...1000 {
            locations.append(CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i)))
        }
        
        tripRecorder.start()
        
        mockLocationManager.send(locations: locations)
        
        XCTAssertTrue(configuration.mockApiSessionManager.isPutCalled)
    }
}

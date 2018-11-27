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
    var rx_scheduler: SerialDispatchQueueScheduler {
        get {
            return MainScheduler.asyncInstance
        }
    }
    
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
     
    func testInit_LocationFeature() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let tripRecorder = TripRecorder(config: configuration)
        
        var locations = [CLLocation]()
        
        tripRecorder.start()
        
        for i in 0...100 {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
            mockLocationManager.send(locations: [location])
        }
        
        
        tripRecorder.stop()
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 5).first() {
                XCTAssertEqual(trip.event[0], EventType.start)
                XCTAssertEqual(trip.event[1], EventType.stop)
                XCTAssertEqual(trip.event.count, 2)
                XCTAssertEqual(trip.count, 100)
            }
        } catch {
            XCTAssertFalse(true)
        }
        
        XCTAssertTrue(configuration.mockApiSessionManager.isPutCalled)
    }
}

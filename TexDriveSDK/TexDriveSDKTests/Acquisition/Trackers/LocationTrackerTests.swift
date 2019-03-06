//
//  LocationTrackerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CoreLocation

@testable import TexDriveSDK

class MockLocationManager: LocationManager {
    var mockCLLocationManager = MockCLLocationManager()
}

class MockCLLocationManager: CLLocationManager {
    static var mockAuthorizationStatus: CLAuthorizationStatus?
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return mockAuthorizationStatus!
    }
    
    var isStartUpdatingLocationCalled = false
    
    override func startUpdatingLocation() {
        isStartUpdatingLocationCalled = true
    }
    
    var isStopUpdatingLocationCalled = false
    override func stopUpdatingLocation() {
        isStopUpdatingLocationCalled = true
    }
    
    var mockPausesLocationUpdatesAutomatically = true
    
    override var pausesLocationUpdatesAutomatically: Bool {
        get {
            return mockPausesLocationUpdatesAutomatically
        }
        set {
            mockPausesLocationUpdatesAutomatically = newValue
        }
    }
    var mockAllowsBackgroundLocationUpdates = false
    override var allowsBackgroundLocationUpdates : Bool {
        get {
            return mockAllowsBackgroundLocationUpdates
        }
        set {
            mockAllowsBackgroundLocationUpdates = newValue
        }
    }
    
    func send(locations: [CLLocation]) {
        for location in locations {
            self.delegate?.locationManager!(self, didUpdateLocations: [location])
        }
    }
}

class LocationTrackerTests: XCTestCase {
    var mockLocationManager :  LocationManager?
    var locationTracker : LocationTracker?
    
    override func setUp() {
        super.setUp()
        mockLocationManager = LocationManager()
        locationTracker = LocationTracker(sensor: mockLocationManager!)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    // MARK: func enableTracking()
    
    // MARK: func disableTracking()
    func testDisableTracking() {
        locationTracker?.disableTracking()

        XCTAssertNil(locationTracker?.rxDisposeBag)
    }

    
    func testLocationManagerDidUpdateLocation_onNext() {
        let date = Date(timeIntervalSinceNow: 9999)
        let latitude = 48.81
        let longitude = 2.3472
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let precision = 5.1
        let speed = 1.2
        let bearing = 1.3
        let altitude = 1.4
        let location = CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: precision, verticalAccuracy: 1.1, course: bearing, speed: speed, timestamp: date)
        
        let locations = [location]
        
        let subscribe = locationTracker!.provideFix().asObservable().subscribe({ (event) in
            switch event.element {
            case Result.Success(let locationFix)?:
                XCTAssertEqual(locationFix.timestamp, date.timeIntervalSince1970)
                XCTAssertEqual(locationFix.longitude, longitude)
                XCTAssertEqual(locationFix.altitude, altitude)
                XCTAssertEqual(locationFix.precision, precision)
                XCTAssertEqual(locationFix.speed, speed)
                XCTAssertEqual(locationFix.bearing, bearing)
                XCTAssertEqual(locationFix.altitude, altitude)
                break
            default:
                XCTAssertTrue(false)
                break
            }
        })
        
        locationTracker?.didUpdateLocations(location: location)
        
        subscribe.dispose()
    }
    
}

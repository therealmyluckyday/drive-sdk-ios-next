//
//  LocationTrackerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift

@testable import TexDriveSDK


class LocationTrackerTests: XCTestCase {
    var locationTracker : LocationTracker?
    var locationSensor : LocationSensor?
    
    override func setUp() {
        super.setUp()
        
        locationTracker = LocationTracker(sensor: LocationSensor(CLLocationManager()))
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

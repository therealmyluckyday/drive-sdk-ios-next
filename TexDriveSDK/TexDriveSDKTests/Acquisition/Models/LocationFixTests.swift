//
//  LocationFixTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class LocationFixTests: XCTestCase {
    // MARK: init(timestamp: Date, latitude: Double, longitude: Double, precision: Double, speed: Double, bearing: Double, altitude: Double) 
    func testInit_timestamp_check() {
        let date = Date(timeIntervalSinceNow: 9999)
        let latitude = 48.886951
        let longitude = 2.343072
        let precision = 5.1
        let speed = 1.2
        let bearing = 1.3
        let altitude = 1.4
        
        let locationFix = LocationFix(timestamp: date.timeIntervalSince1970, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
        
        XCTAssertEqual(locationFix.timestamp, date.timeIntervalSince1970)
    }
    
    func testInit_general_check() {
        let date = Date(timeIntervalSinceNow: 9999)
        let latitude = 48.81
        let longitude = 2.3472
        let precision = 5.1
        let speed = 1.2
        let bearing = 1.3
        let altitude = 1.4
        
        let locationFix = LocationFix(timestamp: date.timeIntervalSince1970, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
        
        XCTAssertEqual(locationFix.latitude, latitude)
        XCTAssertEqual(locationFix.longitude, longitude)
        XCTAssertEqual(locationFix.precision, precision)
        XCTAssertEqual(locationFix.speed, speed)
        XCTAssertEqual(locationFix.bearing, bearing)
        XCTAssertEqual(locationFix.altitude, altitude)
    }
}

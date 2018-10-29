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
        let latitude = 48.8118888188181
        let longitude = 2.8118881188181
        let precision = 5.18118888188181
        let speed = 1.28118888188181
        let bearing = 1.38118888188181
        let altitude = 1.48118888188181
        
        let locationFix = LocationFix(timestamp: date.timeIntervalSince1970, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
        
        XCTAssertEqual(locationFix.latitude, latitude)
        XCTAssertEqual(locationFix.longitude, longitude)
        XCTAssertEqual(locationFix.precision, precision)
        XCTAssertEqual(locationFix.speed, speed)
        XCTAssertEqual(locationFix.bearing, bearing)
        XCTAssertEqual(locationFix.altitude, altitude)
    }
    
    // MARK: func serialize() -> [String : Any]
    func testSerialize() {
        let timestamp = Date().timeIntervalSince1970
        let latitude = 48.8118888188181
        let longitude = 2.34724562335
        let precision = 5.1
        let speed = 1.2
        let bearing = 1.3
        let altitude = 1.4567788865555
        
        let locationFix = LocationFix(timestamp: timestamp, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
        
        let result = locationFix.serialize()
        
        let detailResult = result["location"] as! [String : Any]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(detailResult["latitude"] as! Double, 48.811889)
        XCTAssertEqual(detailResult["longitude"] as! Double, 2.347246)
        XCTAssertEqual(detailResult["precision"] as! Double, precision)
        XCTAssertEqual(detailResult["speed"] as! Double, speed)
        XCTAssertEqual(detailResult["bearing"] as! Double, bearing)
        XCTAssertEqual(detailResult["altitude"] as! Double, 1.456779)
        XCTAssertEqual(result["timestamp"] as! Int, Int(timestamp*1000))
    }
}

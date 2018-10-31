//
//  TripTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 29/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class TripTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: func canUpload() -> Bool
    func testCanUploadNoCrashReturnFalse() {
        let trip = Trip()
        
        let result = trip.canUpload()
        
        XCTAssertFalse(result)
    }
    
    func testCanUploadNoCrashReturnTrue() {
        let trip = Trip()
        let timestamp = Date().timeIntervalSince1970
        let level = Float(-1.0)
        let state = BatteryState.plugged
        let fix = BatteryFix(timestamp: timestamp, level: level, state: state)
        
        var i = 0
        while i <= TripConstant.MinFixesToSend {
            trip.append(fix: fix)
            i += 1
        }
        
        let result = trip.canUpload()
        
        XCTAssertTrue(result)
    }
    
    func testCanUploadWithCrashReturnTrue() {
        let trip = Trip()
        let timestamp = Date().timeIntervalSince1970
        let level = Float(-1.0)
        let state = BatteryState.plugged
        let fix = BatteryFix(timestamp: timestamp, level: level, state: state)
        
        trip.append(eventType: EventType.crash)
        
        var i = 0
        while i <= TripConstant.MinFixesToSend {
            trip.append(fix: fix)
            i += 1
        }
        
        let result = trip.canUpload()
        
        XCTAssertTrue(result)
    }
    
    func testCanUploadWithCrashReturnFalse() {
        let trip = Trip()
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 0.8118888188181, y: 1.8118888188181, z: 2.8118881188181)
        let gavityMotion = XYZAxisValues(x: 3.8118888188181, y: 4.8118888188181, z: 5.8118881188181)
        let magnetometerMotion = XYZAxisValues(x: 6.8118888188181, y: 7.8118888188181, z: 8.8118881188181)
        let fix = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gavityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        
        trip.append(eventType: EventType.crash)
        
        var i = 0
        while i <= TripConstant.MinFixesToSend {
            trip.append(fix: fix)
            i += 1
        }
        
        let result = trip.canUpload()
        
        XCTAssertFalse(result)
    }
    
    // MARK: func append(fix: Fix)
    func testAppendFix() {
        let trip = Trip()
        let timestamp = Date().timeIntervalSince1970
        let level = Float(-1.0)
        let state = BatteryState.plugged
        let battery = BatteryFix(timestamp: timestamp, level: level, state: state)
        
        trip.append(fix: battery)
        trip.append(fix: battery)
        trip.append(fix: battery)
        trip.append(fix: battery)
        trip.append(fix: battery)
        trip.append(fix: battery)
        trip.append(fix: battery)
        trip.append(fix: battery)
        trip.append(fix: battery)
        
        XCTAssertEqual(trip.count, 9)
    }
    
    // MARK: func append(eventType: EventType)
    func testAppendEvent() {
        let trip = Trip()
        
        trip.append(eventType: EventType.start)
        trip.append(eventType: EventType.stop)
        trip.append(eventType: EventType.callBusy)
        trip.append(eventType: EventType.callIdle)
        trip.append(eventType: EventType.callRinging)
        trip.append(eventType: EventType.crash)
        
        XCTAssertEqual(trip.event.count, 6)
    }
    
    // MARK: init(tripId: String)
    func testConvenienceInit() {
        let tripId = UIDevice.current.identifierForVendor!.uuidString
        
        let trip = Trip()
        
        XCTAssertTrue(trip.tripId.contains(tripId))
    }
    
    func testInitWithTripId() {
        let tripId = "MYTRIIIPID"
        
        let trip = Trip(tripId: tripId)
        
        XCTAssertEqual(trip.tripId, tripId)
    }
    
    // MARK: func serialize() -> [String : Any]
    func testSerializeEmpty() {
        let tripId = "MYTRIIIPID"
        let trip = Trip(tripId: tripId)
        
        let result = trip.serialize()
        
        let detailResult = result["fixes"] as! [[String : Any]]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(result["trip_id"] as! String, tripId)
        XCTAssertEqual(detailResult.count, 1)
        let eventFix = detailResult[0]
        XCTAssertNotNil(eventFix["timestamp"])
        let events = eventFix["event"] as! [String]
        XCTAssertEqual(events.count, 0)
    }
    
    func testSerializeWithAllEventsType() {
        let tripId = "MYTRIIIPID"
        let trip = Trip(tripId: tripId)
        trip.append(eventType: EventType.start)
        trip.append(eventType: EventType.stop)
        trip.append(eventType: EventType.callIdle)
        trip.append(eventType: EventType.callRinging)
        trip.append(eventType: EventType.callBusy)
        trip.append(eventType: EventType.crash)
        
        let result = trip.serialize()
        
        let detailResult = result["fixes"] as! [[String : Any]]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(result["trip_id"] as! String, tripId)
        XCTAssertEqual(detailResult.count, 1)
        let eventFix = detailResult[0]
        XCTAssertNotNil(eventFix["timestamp"])
        let events = eventFix["event"] as! [String]
        XCTAssertEqual(events.count, 6)
        XCTAssertTrue(events.contains("start"))
        XCTAssertTrue(events.contains("stop"))
        XCTAssertTrue(events.contains("crash"))
        XCTAssertTrue(events.contains("call_idle"))
        XCTAssertTrue(events.contains("call_ringing"))
        XCTAssertTrue(events.contains("call_busy"))
    }
    
    
    func testSerializeWithBatteryFix() {
        let tripId = "MYTRIIIPID"
        let trip = Trip(tripId: tripId)
        // Battery Fix
        let timestamp = Date().timeIntervalSince1970
        let level = Float(-1.0)
        let state = BatteryState.plugged
        let battery = BatteryFix(timestamp: timestamp, level: level, state: state)
        trip.append(fix: battery)
        
        let result = trip.serialize()
        
        let detailResult = result["fixes"] as! [[String : Any]]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(result["trip_id"] as! String, tripId)
        XCTAssertEqual(detailResult.count, 2)
        let eventFix = detailResult[1]
        XCTAssertNotNil(eventFix["timestamp"])
        let events = eventFix["event"] as! [String]
        XCTAssertEqual(events.count, 0)
        let batteryFixResult = detailResult[0]
        let batteryResult = batteryFixResult["battery"] as! [String : Any]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(batteryResult["level"] as! Int, 0)
        XCTAssertEqual(batteryResult["state"] as! String, state.rawValue)
        XCTAssertEqual(batteryFixResult["timestamp"] as! Int, Int(timestamp*1000))
    }
    
    func testSerializeWithLocationFix() {
        let tripId = "MYTRIIIPID"
        let trip = Trip(tripId: tripId)
        // Location Fix
        let timestamp = Date().timeIntervalSince1970
        let latitude = 48.8118888188181
        let longitude = 2.34724562335
        let precision = 5.1
        let speed = 1.2
        let bearing = 1.3
        let altitude = 1.4567788865555
        let locationFix = LocationFix(timestamp: timestamp, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
        trip.append(fix: locationFix)
        
        let result = trip.serialize()
        
        let detailResult = result["fixes"] as! [[String : Any]]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(result["trip_id"] as! String, tripId)
        XCTAssertEqual(detailResult.count, 2)
        let eventFix = detailResult[1]
        XCTAssertNotNil(eventFix["timestamp"])
        let events = eventFix["event"] as! [String]
        XCTAssertEqual(events.count, 0)
        let locationFixResult = detailResult[0]
        let locationDetailResult = locationFixResult["location"] as! [String : Any]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(locationDetailResult["latitude"] as! Double, latitude)
        XCTAssertEqual(locationDetailResult["longitude"] as! Double, longitude)
        XCTAssertEqual(locationDetailResult["precision"] as! Double, Double(precision))
        XCTAssertEqual(locationDetailResult["speed"] as! Double, Double(speed))
        XCTAssertEqual(locationDetailResult["bearing"] as! Double, Double(bearing))
        XCTAssertEqual(locationDetailResult["altitude"] as! Double, altitude)
        XCTAssertEqual(locationFixResult["timestamp"] as! Int, Int(timestamp*1000))
    }
    
    func testSerializeWithMotionFix() {
        let tripId = "MYTRIIIPID"
        let trip = Trip(tripId: tripId)
        // Motion Fix
        let timestamp = Date().timeIntervalSinceNow
        let accelerationMotion = XYZAxisValues(x: 0.8118888188181, y: 1.8118888188181, z: 2.8118881188181)
        let gravityMotion = XYZAxisValues(x: 3.8118888188181, y: 4.8118888188181, z: 5.8118881188181)
        let magnetometerMotion = XYZAxisValues(x: 6.8118888188181, y: 7.8118888188181, z: 8.8118881188181)
        let motionFix = MotionFix(timestamp: timestamp, accelerationMotion: accelerationMotion, gravityMotion: gravityMotion, magnetometerMotion: magnetometerMotion, crashDetected: true)
        trip.append(fix: motionFix)
        
        
        let result = trip.serialize()
        
        let detailResult = result["fixes"] as! [[String : Any]]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(result["trip_id"] as! String, tripId)
        XCTAssertEqual(detailResult.count, 2)
        let eventFix = detailResult[1]
        XCTAssertNotNil(eventFix["timestamp"])
        let events = eventFix["event"] as! [String]
        XCTAssertEqual(events.count, 0)
    
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        
        let motionResult = detailResult[0]
        let motionDetailResult = motionResult["motion"] as! [String : Any]
        let magnetometerResult = motionDetailResult["magnetometer"] as! [String : Any]
        XCTAssertEqual(magnetometerResult["x"] as! Double, magnetometerMotion.x)
        XCTAssertEqual(magnetometerResult["y"] as! Double, magnetometerMotion.y)
        XCTAssertEqual(magnetometerResult["z"] as! Double, magnetometerMotion.z)
        let gravityResult = motionDetailResult["gravity"] as! [String : Any]
        XCTAssertEqual(gravityResult["x"] as! Double, gravityMotion.x)
        XCTAssertEqual(gravityResult["y"] as! Double, gravityMotion.y)
        XCTAssertEqual(gravityResult["z"] as! Double, gravityMotion.z)
        let accelerationResult = motionDetailResult["acceleration"] as! [String : Any]
        XCTAssertEqual(accelerationResult["x"] as! Double, accelerationMotion.x)
        XCTAssertEqual(accelerationResult["y"] as! Double, accelerationMotion.y)
        XCTAssertEqual(accelerationResult["z"] as! Double, accelerationMotion.z)
        let realtimestamp = Date(timeInterval: timestamp, since: Date.init(timeIntervalSinceNow: -1 * ProcessInfo.processInfo.systemUptime)).timeIntervalSince1970
        XCTAssertEqual(motionResult["timestamp"] as! Int, Int(realtimestamp*1000))
    }
}

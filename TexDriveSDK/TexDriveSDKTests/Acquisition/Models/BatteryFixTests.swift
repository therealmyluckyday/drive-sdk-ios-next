//
//  BatteryFixTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class BatteryFixTests: XCTestCase {
    // MARK: init (timestamp: date.timeIntervalSince1970, level: Float, state: BatteryState)
    func testInit_state_unplugged() {
        let date = Date()
        let level = Float(1)
        let state = BatteryState.unplugged
        let battery = BatteryFix(timestamp: date.timeIntervalSince1970, level: level, state: state)
        
        XCTAssertEqual(battery.state, state)
    }
    
    func testInit_state_plugged() {
        let date = Date()
        let level = Float(1)
        let state = BatteryState.plugged
        let battery = BatteryFix(timestamp: date.timeIntervalSince1970, level: level, state: state)
        
        XCTAssertEqual(battery.state, state)
    }
    
    func testInit_state_unknown() {
        let date = Date()
        let level = Float(1)
        let state = BatteryState.unknown
        let battery = BatteryFix(timestamp: date.timeIntervalSince1970, level: level, state: state)
        
        XCTAssertEqual(battery.state, state)
    }
    
    func testInit_level_maxed() {
        let date = Date()
        let level = Float(1.0)
        let state = BatteryState.unplugged
        let battery = BatteryFix(timestamp: date.timeIntervalSince1970, level: level, state: state)
        
        XCTAssertEqual(battery.level, level)
    }
    
    func testInit_level_unknown() {
        let date = Date()
        let level = Float(-1.0)
        let state = BatteryState.unplugged
        let battery = BatteryFix(timestamp: date.timeIntervalSince1970, level: level, state: state)
        
        XCTAssertEqual(battery.level, level)
    }
    
    func testInit_level_min() {
        let date = Date()
        let level = Float(0.0)
        let state = BatteryState.unplugged
        let battery = BatteryFix(timestamp: date.timeIntervalSince1970, level: level, state: state)
        
        XCTAssertEqual(battery.level, level)
    }
    
    func testInit_timestamp_check() {
        let date = Date(timeIntervalSinceNow: 9999)
        let level = Float(0.0)
        let state = BatteryState.unplugged
        let battery = BatteryFix(timestamp: date.timeIntervalSince1970, level: level, state: state)
        
        XCTAssertEqual(battery.timestamp, date.timeIntervalSince1970)
    }
    // MARK: func serialize() -> [String : Any]
    func testSerializeBatteryLevelMoreThan0() {
        let timestamp = Date().timeIntervalSince1970
        let level = Float(10.0)
        let state = BatteryState.unplugged
        let battery = BatteryFix(timestamp: timestamp, level: level, state: state)
        
        let result = battery.serialize()
        
        let batteryResult = result["battery"] as! [String : Any]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(batteryResult["level"] as! Int, Int(level*100))
        XCTAssertEqual(batteryResult["state"] as! String, state.rawValue)
        XCTAssertEqual(result["timestamp"] as! Int, Int(timestamp*1000))
    }
    
    func testSerializeBatteryLevelLessThan0() {
        let timestamp = Date().timeIntervalSince1970
        let level = Float(-1.0)
        let state = BatteryState.plugged
        let battery = BatteryFix(timestamp: timestamp, level: level, state: state)
        
        let result = battery.serialize()
        
        let batteryResult = result["battery"] as! [String : Any]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertEqual(batteryResult["level"] as! Int, 0)
        XCTAssertEqual(batteryResult["state"] as! String, state.rawValue)
        XCTAssertEqual(result["timestamp"] as! Int, Int(timestamp*1000))
    }
}

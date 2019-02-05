//
//  EventTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 30/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest

@testable import TexDriveSDK

class EventTests: XCTestCase {


    // MARK: func serialize() -> [String : Any]
    func testSerializeWithStartEventType() {
        let event = Event(eventType: EventType.start, timestamp: Date().timeIntervalSince1970)
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains("start"))
    }

    //        event.append(eventType: EventType.stop)
    //        event.append(eventType: EventType.callIdle)
    //        event.append(eventType: EventType.callRinging)
    //        event.append(eventType: EventType.callRinging)
    //        event.append(eventType: EventType.callBusy)
    //        event.append(eventType: EventType.crash)
    
    func testSerializeWithStopEventType() {
        let event = Event(eventType: EventType.stop, timestamp: Date().timeIntervalSince1970)
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains("stop"))
    }
    
    func testSerializeCallIdleEventType() {
        let event = Event(eventType: EventType.callIdle, timestamp: Date().timeIntervalSince1970)
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains("call_idle"))
    }
    func testSerializeWithCallBusyEventType() {
        let event = Event(eventType: EventType.callBusy, timestamp: Date().timeIntervalSince1970)
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains("call_busy"))
    }
    
    func testSerializeWithCallRingingEventType() {
        let event = Event(eventType: EventType.callRinging, timestamp: Date().timeIntervalSince1970)
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains("call_ringing"))
    }
    func testSerializeWithCrashEventType() {
        let event = Event(eventType: EventType.crash, timestamp: Date().timeIntervalSince1970)
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events.contains("crash"))
    }
    
}

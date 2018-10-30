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
    func testSerializeWithAllEventsType() {
        let event = Event()
        event.append(eventType: EventType.start)
        event.append(eventType: EventType.stop)
        event.append(eventType: EventType.callIdle)
        event.append(eventType: EventType.callRinging)
        event.append(eventType: EventType.callRinging)
        event.append(eventType: EventType.callBusy)
        event.append(eventType: EventType.crash)
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 6)
        XCTAssertTrue(events.contains("start"))
        XCTAssertTrue(events.contains("stop"))
        XCTAssertTrue(events.contains("crash"))
        XCTAssertTrue(events.contains("call_idle"))
        XCTAssertTrue(events.contains("call_ringing"))
        XCTAssertTrue(events.contains("call_busy"))
    }
    
    func testSerializeWithNoEventsType() {
        let event = Event()
        
        let result = event.serialize()
        
        let events = result["event"] as! [String]
        XCTAssertTrue(JSONSerialization.isValidJSONObject(result))
        XCTAssertNotNil(result["timestamp"])
        XCTAssertEqual(events.count, 0)
        XCTAssertFalse(events.contains("start"))
        XCTAssertFalse(events.contains("stop"))
        XCTAssertFalse(events.contains("crash"))
        XCTAssertFalse(events.contains("call_idle"))
        XCTAssertFalse(events.contains("call_ringing"))
        XCTAssertFalse(events.contains("call_busy"))
    }
    
}

//
//  CallFixTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 15/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class CallFixTests: XCTestCase {
    // MARK: init(date: Date, callState: CallFixState)
    func testInit_date() {
        let date = Date(timeIntervalSinceNow: 9999)
        
        let call = CallFix(timestamp: date.timeIntervalSince1970, state: CallFixState.ringing)
        
        XCTAssertEqual(call.timestamp, date.timeIntervalSince1970)
    }
    
    func testInit_State_Ringing() {
        let date = Date(timeIntervalSinceNow: 9999)
        
        let call = CallFix(timestamp: date.timeIntervalSince1970, state: CallFixState.ringing)
        
        XCTAssertEqual(call.state, CallFixState.ringing)
    }
    
    func testInit_State_Idle() {
        let date = Date(timeIntervalSinceNow: 9999)
        
        let call = CallFix(timestamp: date.timeIntervalSince1970, state: CallFixState.idle)
        
        XCTAssertEqual(call.state, CallFixState.idle)
    }
    
    func testInit_State_Busy() {
        let date = Date(timeIntervalSinceNow: 9999)
        
        let call = CallFix(timestamp: date.timeIntervalSince1970, state: CallFixState.busy)
        
        XCTAssertEqual(call.state, CallFixState.busy)
    }
    
}

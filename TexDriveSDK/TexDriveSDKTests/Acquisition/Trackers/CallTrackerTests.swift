//
//  CallTrackerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 15/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import CallKit

@testable import TexDriveSDK

class MockCallObserver: CXCallObserver {
    var mockDelegateSetted: CXCallObserverDelegate?
    var isSetDelegateCalled = false
    
    override func setDelegate(_ delegate: CXCallObserverDelegate?, queue: DispatchQueue?) {
        mockDelegateSetted = delegate
        isSetDelegateCalled = true
        super.setDelegate(delegate, queue: queue)
    }
}

class CallTrackerTests: XCTestCase {
    private var mockCallObserver: MockCallObserver?
    private var callTracker: CallTracker?
    
    override func setUp() {
        super.setUp()
        mockCallObserver = MockCallObserver()
        callTracker = CallTracker(sensor: mockCallObserver!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK : func enableTracking() {
    func testEnableTracking_setDelegate() {
        XCTAssertFalse(mockCallObserver!.isSetDelegateCalled)
        callTracker?.disableTracking()
        
        XCTAssertNil(mockCallObserver!.mockDelegateSetted)
        
        callTracker?.enableTracking()
        
        
        XCTAssertNotNil(mockCallObserver!.mockDelegateSetted)
        XCTAssertTrue(mockCallObserver!.isSetDelegateCalled)
    }
    
    
    // MARK : func disableTracking() {
    func testDisableTracking_setDelegate() {
        XCTAssertFalse(mockCallObserver!.isSetDelegateCalled)
        callTracker?.enableTracking()
        XCTAssertNotNil(mockCallObserver!.mockDelegateSetted)
        
        callTracker?.disableTracking()
        
        XCTAssertNil(mockCallObserver!.mockDelegateSetted)
        XCTAssertTrue(mockCallObserver!.isSetDelegateCalled)
    }
    
    // MARK : func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall)
    func testCallObserverCXall_firstCall_to_state_idle() {
        // TEST NOT BE CALLED
        var isNotCalled = true
        let subscribe = callTracker!.provideFix().asObservable().subscribe({ (event) in
            isNotCalled = false
            XCTAssertTrue(false)
        })
        
        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.idle))
        
        subscribe.dispose()
        XCTAssertTrue(isNotCalled)
    }
    
    func testCallObserverCXall_idle_to_state_idle() {
        
        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.idle))
        
        var isNotCalled = true
        // TEST NOT BE CALLED
        let subscribe = callTracker!.provideFix().asObservable().subscribe({ (event) in
            isNotCalled = false
            XCTAssertTrue(false)
        })
        
        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.idle))
        
        subscribe.dispose()
        XCTAssertTrue(isNotCalled)
    }
    
    func testCallObserverCXall_idle_to_state_ringing() {
        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.idle))
        
        var isCalled = false
        let subscribe = callTracker!.provideFix().asObservable().subscribe({ (event) in
            isCalled = true
            switch event.element {
            case Result.Success(let callFix)?:
                XCTAssertNotNil(callFix.timestamp)
                XCTAssertEqual(callFix.state, CallFixState.ringing)
                break
            default:
                XCTAssertTrue(false)
                break
            }
        })
        
        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.ringing))

        
        subscribe.dispose()
        XCTAssertTrue(isCalled)
    }
    
    func testCallObserverCXall_idle_to_state_busy() {

        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.idle))
        
        var isCalled = false
        let subscribe = callTracker!.provideFix().asObservable().subscribe({ (event) in
            isCalled = true
            switch event.element {
            case Result.Success(let callFix)?:
                XCTAssertNotNil(callFix.timestamp)
                XCTAssertEqual(callFix.state, CallFixState.busy)
                break
            default:
                XCTAssertTrue(false)
                break
            }
        })

        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.busy))
        
        subscribe.dispose()
        XCTAssertTrue(isCalled)
    }
    
    
    
    func testCallObserverCXall_busy_to_state_idle() {

        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.busy))
        
        var isCalled = false
        let subscribe = callTracker!.provideFix().asObservable().subscribe({ (event) in
            isCalled = true
            switch event.element {
            case Result.Success(let callFix)?:
                XCTAssertNotNil(callFix.timestamp)
                XCTAssertEqual(callFix.state, CallFixState.idle)
                break
            default:
                XCTAssertTrue(false)
                break
            }
        })
        

        callTracker!.newCallfFix(callFix: CallFix(timestamp: Date().timeIntervalSince1970, state: CallFixState.idle))
        
        subscribe.dispose()
        XCTAssertTrue(isCalled)
    }
    
}

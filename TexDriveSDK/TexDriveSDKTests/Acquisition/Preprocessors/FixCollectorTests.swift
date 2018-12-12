//
//  FixCollectorTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
@testable import TexDriveSDK
class MockFix: Fix {
    var timestamp: TimeInterval = 0.0
    var description: String = "REXORAOOM"
    func serialize() -> [String : Any] {
        return [String: Any]()
    }
}

class MockTracker: Tracker {
    typealias T = MockFix
    let provider = PublishSubject<Result<MockFix>>()
    func provideFix() -> (PublishSubject<Result<T>>) {
        return provider
    }
    var isEnableTrackingCalled = false
    func enableTracking() {
        isEnableTrackingCalled = true
    }
    var isDisableTrackingCalled = false
    func disableTracking() {
        isDisableTrackingCalled = true
    }
}

class FixCollectorTests: XCTestCase {
    // MARK : func collect<T>(tracker: T) where T: Tracker
    func testCollectTrackerTestSuccess() {
        let mockTracker = MockTracker()
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let fixToSend = MockFix()
        
        let fixCollector = FixCollector(eventsType: eventType, fixes: fixes, scheduler: MainScheduler.instance)
        fixCollector.collect(tracker: mockTracker)
        
        var isCallSubscribe = false
        let disposable = fixes.asObserver().subscribe { (event) in
            if let fix = event.element {
                isCallSubscribe = true
                XCTAssertEqual(fix.description, fixToSend.description)
            }
        }
        mockTracker.provider.onNext(Result.Success(fixToSend))
        XCTAssertTrue(isCallSubscribe)
        disposable.dispose()
    }
    
    func testCollectTrackerTestFailure() {
        let mockTracker = MockTracker()
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let fixToSend = MockFix()
        let error = NSError(domain: "TEST", code: 044, userInfo: nil)
        let fixCollector = FixCollector(eventsType: eventType, fixes: fixes, scheduler: MainScheduler.instance)
        var isCallSubscribeRxError = false
        let disposableRxError = fixCollector.rxErrorCollecting.asObserver().subscribe { (event) in
            if event.element != nil {
                isCallSubscribeRxError = true
            }
        }
        
        fixCollector.collect(tracker: mockTracker)
        
        var isCallSubscribe = false
        let disposable = fixes.asObserver().subscribe { (event) in
            if let fix = event.element {
                isCallSubscribe = true
                XCTAssertEqual(fix.description, fixToSend.description)
            }
        }
        mockTracker.provider.onNext(Result.Failure(error))
        XCTAssertFalse(isCallSubscribe)
        XCTAssertTrue(isCallSubscribeRxError)
        disposable.dispose()
        disposableRxError.dispose()
    }
    
    // MARK : func startCollect()
    func testStartCollect() {
        let mockTracker = MockTracker()
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let fixCollector = FixCollector(eventsType: eventType, fixes: fixes, scheduler: MainScheduler.instance)
        fixCollector.collect(tracker: mockTracker)
        var isCallSubscribe = false
        let disposable = eventType.asObserver().subscribe { (event) in
            if let eventType = event.element {
                isCallSubscribe = true
                XCTAssertEqual(eventType, EventType.start)
            }
        }
        
        fixCollector.startCollect()
        
        XCTAssertTrue(isCallSubscribe)
        XCTAssertTrue(mockTracker.isEnableTrackingCalled)
        disposable.dispose()
    }
    
    // MARK : func stopCollect()
    func testStopCollect() {
        let mockTracker = MockTracker()
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let fixCollector = FixCollector(eventsType: eventType, fixes: fixes, scheduler: MainScheduler.instance)
        fixCollector.collect(tracker: mockTracker)
        var isCallSubscribe = false
        let disposable = eventType.asObserver().subscribe { (event) in
            if let eventType = event.element {
                isCallSubscribe = true
                XCTAssertEqual(eventType, EventType.stop)
            }
        }
        
        
        fixCollector.stopCollect()
        
        XCTAssertTrue(isCallSubscribe)
        XCTAssertTrue(mockTracker.isDisableTrackingCalled)
        disposable.dispose()
    }
}

//
//  FixCollectorTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
@testable import TexDriveSDK
class MockFix: Fix {
    var timestamp: TimeInterval = 0.0
    var description: String = "REXORAOOM"
    func serialize() -> [String : Any] {
        return [String: Any]()
    }
    func serializeAPIV2() -> [String: Any] {
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
    // MARK: - func collect<T>(tracker: T) where T: Tracker
    func testCollectTrackerTestSuccess() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let fixToSend = LocationFix(timestamp: TimeInterval(0), latitude: 0.1, longitude: 0.2, precision: 2, speed: 3, bearing: 4, altitude: 5, distance: 1)
        let isCallSubscribeExpectation = XCTestExpectation(description: "isCallSubscribeExpectation")
        let fixCollector = FixCollector(eventsType: eventType, fixes: fixes, scheduler: MainScheduler.instance)
        let fakeLocationSensor = FakeLocationSensor()
        let locationTracker = LocationTracker(sensor: fakeLocationSensor)
        fixCollector.collect(tracker: locationTracker)
        
        let disposable = fixes.asObserver().subscribe { (event) in
            if let fix = event.element {
                isCallSubscribeExpectation.fulfill()
                XCTAssertEqual(fix.description, fixToSend.description)
            }
        }
        locationTracker.provideFix().onNext(Result.Success(fixToSend))
        wait(for: [isCallSubscribeExpectation], timeout: TimeInterval(5), enforceOrder: false)
        
        disposable.dispose()
    }
    
    func testCollectTrackerTestFailure() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let fixToSend = MockFix()
        let isNotCallSubscribeExpectation = XCTestExpectation(description: "isCallSubscribeExpectation")
        isNotCallSubscribeExpectation.isInverted = true
        let error = NSError(domain: "TEST", code: 044, userInfo: nil)
        let fixCollector = FixCollector(eventsType: eventType, fixes: fixes, scheduler: MainScheduler.instance)
        let fakeLocationSensor = FakeLocationSensor()
        let locationTracker = LocationTracker(sensor: fakeLocationSensor)
        let isCallSubscribeRxErrorExpectation = XCTestExpectation(description: "isCallSubscribeRxError")
        let disposableRxError = fixCollector.rxErrorCollecting.asObserver().subscribe { (event) in
            if event.element != nil {
                isCallSubscribeRxErrorExpectation.fulfill()
            }
        }
        
        fixCollector.collect(tracker: locationTracker)
        
        let disposable = fixes.asObserver().subscribe { (event) in
            if let fix = event.element {
                isNotCallSubscribeExpectation.fulfill()
                XCTAssertEqual(fix.description, fixToSend.description)
            }
        }
        locationTracker.provideFix().onNext(Result.Failure(error))
        wait(for: [isNotCallSubscribeExpectation, isCallSubscribeRxErrorExpectation], timeout: TimeInterval(5))
        disposable.dispose()
        disposableRxError.dispose()
    }
    
    // MARK: - func startCollect()
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
    
    // MARK: - func stopCollect()
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

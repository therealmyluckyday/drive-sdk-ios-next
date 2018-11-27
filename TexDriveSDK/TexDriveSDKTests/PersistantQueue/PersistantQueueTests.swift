//
//  PersistantQueueTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK
@testable import RxSwift
@testable import RxBlocking

class PersistantQueueTests: XCTestCase {
    func testProviderTripStart100FixSend() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler)
        var isproviderTripCalled = false
        let _ = persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if let trip = eventTrip.element {
                isproviderTripCalled = true
                XCTAssertEqual(trip.event[0], EventType.start)
                XCTAssertEqual(trip.event.count, 1)
                XCTAssertEqual(trip.count, 101)
            }
        }
        eventType.onNext(EventType.start)
        for i in 0...100 {
            let date = Date(timeIntervalSinceNow: 9999)
            let latitude = 48.886951
            let longitude = 2.343072
            let precision = 5.1
            let speed = 1.2
            let bearing = 1.3
            let altitude = Double(i)
            
            let locationFix = LocationFix(timestamp: date.timeIntervalSince1970, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
            
            fixes.onNext(locationFix)
            
        }
        XCTAssertTrue(isproviderTripCalled)
    }
    
    func testProviderTripStartStop() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler)
        var isproviderTripCalled = false
        let _ = persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if let trip = eventTrip.element {
                isproviderTripCalled = true
                XCTAssertEqual(trip.event[0], EventType.start)
                XCTAssertEqual(trip.event[1], EventType.stop)
                XCTAssertEqual(trip.event.count, 2)
            }
        }
        eventType.onNext(EventType.start)
        for i in 0...10 {
            let date = Date(timeIntervalSinceNow: 9999)
            let latitude = 48.886951
            let longitude = 2.343072
            let precision = 5.1
            let speed = 1.2
            let bearing = 1.3
            let altitude = Double(i)
            
            let locationFix = LocationFix(timestamp: date.timeIntervalSince1970, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
            
            fixes.onNext(locationFix)
            
            eventType.onNext(EventType.stop)
        }
        XCTAssertTrue(isproviderTripCalled)
    }
        //eventType.onNext(EventType.stop)

        
    
    
    func testProviderTrip100FixNotSend() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler)
        var isproviderTripCalled = false
        let _ = persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if eventTrip.element != nil {
                isproviderTripCalled = true
            }
        }
        for i in 0...100 {
            let date = Date(timeIntervalSinceNow: 9999)
            let latitude = 48.886951
            let longitude = 2.343072
            let precision = 5.1
            let speed = 1.2
            let bearing = 1.3
            let altitude = Double(i)
            
            let locationFix = LocationFix(timestamp: date.timeIntervalSince1970, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
            
            fixes.onNext(locationFix)
        }
        XCTAssertFalse(isproviderTripCalled)
    }
    
    
    func testProviderTripStart99FixNotSend() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler)
        var isproviderTripCalled = false
        let _ = persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if eventTrip.element != nil {
                isproviderTripCalled = true
            }
        }
        eventType.onNext(EventType.start)
        for i in 0...99 {
            let date = Date(timeIntervalSinceNow: 9999)
            let latitude = 48.886951
            let longitude = 2.343072
            let precision = 5.1
            let speed = 1.2
            let bearing = 1.3
            let altitude = Double(i)
            
            let locationFix = LocationFix(timestamp: date.timeIntervalSince1970, latitude: latitude, longitude: longitude, precision: precision, speed: speed, bearing: bearing, altitude: altitude)
            
            fixes.onNext(locationFix)
            
        }
        XCTAssertFalse(isproviderTripCalled)
    }
}

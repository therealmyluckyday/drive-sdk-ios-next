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

class PersistantQueueStub : PersistantQueue {
    var isSendNextTripChunk = false
    var isSendTripChunk = false
    override func sendNextTripChunk() {
        isSendNextTripChunk = true
        super.sendNextTripChunk()
    }
    override func sendTripChunk(tripChunk: TripChunk) {
        isSendTripChunk = true
        super.sendTripChunk(tripChunk: tripChunk)
    }
}

class PersistantQueueTests: XCTestCase {
    func testProviderTripStart100FixSend() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripId = PublishSubject<TripId>()
        let disposeBag = DisposeBag()
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent: rxTripChunkSent)
        var isproviderTripCalled = false
        persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if let trip = eventTrip.element {
                isproviderTripCalled = true
                XCTAssertEqual(trip.event!.eventType, EventType.start)
                XCTAssertEqual(trip.count, TripConstant.MinFixesToSend+1)
            }
        }.disposed(by: disposeBag)
        var isTripIdCalled = false
        rxTripId.asObserver().subscribe { (event) in
            isTripIdCalled = event.element != nil
        }.disposed(by: disposeBag)
        
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
        XCTAssertTrue(isTripIdCalled)
    }
    
    func testProviderTripStart() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent: rxTripChunkSent)
        var isproviderTripCalled = false
        let _ = persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if let trip = eventTrip.element {
                isproviderTripCalled = true
                XCTAssertEqual(trip.event!.eventType, EventType.start)
            }
        }
        eventType.onNext(EventType.start)
        for i in 0...TripConstant.MinFixesToSend {
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
    
    func testProviderTripStop() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        var isproviderTripCalled = false
        let _ = persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if let trip = eventTrip.element {
                isproviderTripCalled = true
                XCTAssertEqual(trip.event!.eventType, EventType.stop)
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
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
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
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueue(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        var isproviderTripCalled = false
        let _ = persistantQueue.providerTrip.asObserver().subscribe { (eventTrip) in
            if eventTrip.element != nil {
                isproviderTripCalled = true
            }
        }
        eventType.onNext(EventType.start)
        for i in 0...TripConstant.MinFixesToSend-1 {
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
    
    // MARK: - test rxTripChunkSent
    func testRxTripChunkSent_Success() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueueStub(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        let result = Result.Success(TripId())
        rxTripChunkSent.onNext(result)
        XCTAssertTrue(persistantQueue.isSendNextTripChunk)
    }
    
    func testRxTripChunkSent_Failure() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueueStub(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        let error = APIError(message: "totomessage", statusCode: 666)
        let result = Result<TripId>.Failure(error)
        rxTripChunkSent.onNext(result)
        XCTAssertTrue(persistantQueue.isSendNextTripChunk)
    }
    
    // MARK: - func sendNextTripChunk()
    func testSendNextTrip_POP() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueueStub(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TOTO", user: User.Anonymous, domain: Domain.Preproduction))
        persistantQueue.sendTripChunk(tripChunk: tripChunk)
        //persistantQueue.sendNextTripChunk()
        XCTAssertTrue(persistantQueue.isSendNextTripChunk)
        XCTAssertNotNil(persistantQueue.tripChunkSent)
    }
    func testSendNextTrip_POP_NIL() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueueStub(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        persistantQueue.sendNextTripChunk()
        XCTAssertNil(persistantQueue.tripChunkSent)
    }
    
    // MARK: - func sendTripChunk(tripChunk: TripChunk)
    func testSendTripChunk_tripChunkSent_NOT_NIL() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueueStub(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TOTO", user: User.Anonymous, domain: Domain.Preproduction))
        persistantQueue.tripChunkSent = tripChunk
        persistantQueue.sendTripChunk(tripChunk: tripChunk)
        XCTAssertFalse(persistantQueue.isSendNextTripChunk)
    }
    
    func testSendTripChunk_tripChunkSent_NIL() {
        let eventType = PublishSubject<EventType>()
        let fixes = PublishSubject<Fix>()
        let scheduler = MainScheduler.instance
        let rxTripChunkSent = PublishSubject<Result<TripId>>()
        let rxTripId = PublishSubject<TripId>()
        let persistantQueue = PersistantQueueStub(eventType: eventType, fixes: fixes, scheduler: scheduler, rxTripId: rxTripId, tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction), rxTripChunkSent:rxTripChunkSent)
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TOTO", user: User.Anonymous, domain: Domain.Preproduction))
        persistantQueue.tripChunkSent = nil
        persistantQueue.sendTripChunk(tripChunk: tripChunk)
        XCTAssertTrue(persistantQueue.isSendNextTripChunk)
    }
}

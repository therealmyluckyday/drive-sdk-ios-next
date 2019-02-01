//
//  TripRecorderTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation
@testable import TexDriveSDK
@testable import RxBlocking

class TripRecorderTests: XCTestCase {
    var rxDisposeBag: DisposeBag?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
    }
    
    override func tearDown() {
        rxDisposeBag = nil
        super.tearDown()
    }
    
    // MARK: - init
    func testInit_LocationFeatureStart() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        
        var locations = [CLLocation]()
        
        tripRecorder.start()
        
        for i in 0...TripConstant.MinFixesToSend {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
        }
        
        mockLocationManager.send(locations: locations)
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 0.1).first() {
                XCTAssertEqual(trip.event?.eventType, EventType.start)
                XCTAssertEqual(trip.count, 101)
            }
        } catch {
            XCTAssertFalse(true)
        }
    }
    
    func testInit_LocationFeatureStop() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        
        var locations = [CLLocation]()
        
        tripRecorder.start()
        
        for i in 0...TripConstant.MinFixesToSend {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
        }
        mockLocationManager.send(locations: locations)
        
        tripRecorder.stop()
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 0.1).first() {
                XCTAssertEqual(trip.event?.eventType, EventType.stop)
            }
        } catch {
            XCTAssertFalse(true)
        }
    }
    
    func testInitSubscribeCalled() {
        let publishTrip = PublishSubject<TripChunk>()
        let mock = APITripSessionManagerMock()
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        configuration.rxScheduler = MainScheduler.instance
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction))
        
        publishTrip.onNext(trip)
        tripRecorder.persistantQueue.providerTrip.onNext(trip)
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 0.1).first() {
                XCTAssertEqual(trip.event?.eventType, EventType.stop)
            }
        } catch {
        }
        XCTAssertTrue(mock.isPutCalled)
        XCTAssertNotNil(mock.dictionaryPut)
    }
    
    // MARK: func subscribe(providerTrip: PublishSubject<Trip>)
    func testSubscribe() {
        let publishTrip = PublishSubject<TripChunk>()
        let mock = APITripSessionManagerMock()
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        configuration.rxScheduler = MainScheduler.instance
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction))
        
        tripRecorder.subscribe(providerTrip: publishTrip, scheduler: MainScheduler.instance)
        publishTrip.onNext(trip)
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 0.1).first() {
                XCTAssertEqual(trip.event?.eventType, EventType.stop)
            }
        } catch {
        }
        XCTAssertTrue(mock.isPutCalled)
        XCTAssertNotNil(mock.dictionaryPut)
    }
    
    
    // MARK: - currentTripId
    func testTripIdNull() {
        
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        
        do{
            if let _ = try tripRecorder.rxTripId.toBlocking(timeout: 0.1).first() {
                XCTAssertFalse(true)
            }
        } catch {
            XCTAssertTrue(true)
        }
        
    }
    
    func testCurrentTripIdNotNull() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        
        var locations = [CLLocation]()
        var isRxTripIdCalled = false
        tripRecorder.rxTripId.asObservable().observeOn(configuration.rxScheduler).subscribe {(event) in
            isRxTripIdCalled = true
            XCTAssertNotNil(event.element)
            }.disposed(by: rxDisposeBag!)
        
        tripRecorder.start()
        
        for i in 0...TripConstant.MinFixesToSend {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
        }
        
        mockLocationManager.send(locations: locations)
        do{
            if let _ = try tripRecorder.rxTripId.toBlocking(timeout: 0.1).first() {
            }
        } catch {
        }
        XCTAssertTrue(isRxTripIdCalled)
    }
    
    // MARK: - currentTripId
    func testCurrentTripIdNull() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = TexServices.service(withConfiguration: configuration)
        
        XCTAssertNil(service.tripRecorder.currentTripId)
    }
}



//
//  TripRecorderTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
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
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockCLLocationManager = MockCLLocationManager()
        let locationSensor = LocationSensor(mockCLLocationManager)
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        let expectation = XCTestExpectation(description: #function)

        rxDisposeBag = DisposeBag()
        tripRecorder.persistantQueue.providerTrip.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let trip = event.element {
                XCTAssertEqual(trip.event?.eventType, EventType.start)
                XCTAssertEqual(trip.count, TripConstant.MinFixesToSend + 1)
                expectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        
        for _ in 0...TripConstant.MinFixesToSend {
            let closedRange = ClosedRange<Double>.init(uncheckedBounds: (lower: 0.0, upper: 19))
            let random = Double.random(in: closedRange)
            let location = CLLocation(latitude: CLLocationDegrees(random), longitude: CLLocationDegrees(random))
            locationSensor.rxLocation.onNext(location)
            mockCLLocationManager.send(locations: [location])
        }
        tripRecorder.start()

        for _ in 0...TripConstant.MinFixesToSend {
            let closedRange = ClosedRange<Double>.init(uncheckedBounds: (lower: 0.0, upper: 19))
            let random = Double.random(in: closedRange)
            let location = CLLocation(latitude: CLLocationDegrees(random), longitude: CLLocationDegrees(random))
            locationSensor.rxLocation.onNext(location)
            mockCLLocationManager.send(locations: [location])
        }

        wait(for: [expectation], timeout: 2)
    }
    
    func testInit_LocationFeatureStop() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(MockCLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
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

        locations.forEach { (result) in
            locationSensor.rxLocation.onNext(result)
        }
        
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
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        configuration.rxScheduler = MainScheduler.instance
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction))
        
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
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        configuration.rxScheduler = MainScheduler.instance
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction))
        
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
        
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
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
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        let expectation = XCTestExpectation(description: #function)
        var locations = [CLLocation]()

        tripRecorder.rxTripId.asObservable().observeOn(configuration.rxScheduler).subscribe {(event) in
            expectation.fulfill()
            XCTAssertNotNil(event.element)
            }.disposed(by: rxDisposeBag!)
        
        tripRecorder.start()
        
        for i in 0...TripConstant.MinFixesToSend {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
        }
        locations.forEach { (result) in
            locationSensor.rxLocation.onNext(result)
        }
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - currentTripId
    func testCurrentTripIdNull() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = TexServices.service(configuration: configuration)
        
        XCTAssertNil(service.tripRecorder?.currentTripId)
    }
}



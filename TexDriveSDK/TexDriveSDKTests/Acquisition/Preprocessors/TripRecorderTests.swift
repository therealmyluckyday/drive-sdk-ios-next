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
        let mockLocationManager = FakeLocationManager()
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
            mockLocationManager.fakeTrackerLocationSensor.rxLocation.onNext(location)
        }
        tripRecorder.start()

        for _ in 0...TripConstant.MinFixesToSend {
            let closedRange = ClosedRange<Double>.init(uncheckedBounds: (lower: 0.0, upper: 19))
            let random = Double.random(in: closedRange)
            let location = CLLocation(latitude: CLLocationDegrees(random), longitude: CLLocationDegrees(random))
            mockLocationManager.fakeTrackerLocationSensor.rxLocation.onNext(location)
        }

        wait(for: [expectation], timeout: 10)
    }
    
    func testInit_LocationFeatureStop() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(MockCLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor: autoModeLocationSensor, locationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        let expectation = XCTestExpectation(description: #function)
        
        var locations = [CLLocation]()
        
        tripRecorder.start()
        
        for i in 0...TripConstant.MinFixesToSend {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
        }

        locations.forEach { (result) in
            locationSensor.rxLocation.onNext(result)
        }
        
        tripRecorder.persistantQueue.providerTrip.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let tripChunk = event.element {
                XCTAssertEqual(tripChunk.event?.eventType, EventType.stop)
                expectation.fulfill()
            }
        }.disposed(by: rxDisposeBag!)
        
        tripRecorder.stop()
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testInitSubscribeCalled() {
        let publishTrip = PublishSubject<TripChunk>()
        let mock = APITripSessionManagerMock()
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor: autoModeLocationSensor, locationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        configuration.rxScheduler = MainScheduler.instance
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction, isAPIV2: false))
        let expectation = XCTestExpectation(description: #function)
        publishTrip.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let tripChunk = event.element {
                XCTAssertNil(tripChunk.event?.eventType)
                expectation.fulfill()
            }
            }.disposed(by: rxDisposeBag!)
        publishTrip.onNext(trip)

        tripRecorder.persistantQueue.providerTrip.onNext(trip)
        
        wait(for: [expectation], timeout: 1)
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
        let mockLocationManager = LocationManager(autoModeLocationSensor: autoModeLocationSensor, locationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        configuration.rxScheduler = MainScheduler.instance
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction, isAPIV2: false))
        let expectation = XCTestExpectation(description: #function)
        
        tripRecorder.subscribe(providerTrip: publishTrip, scheduler: MainScheduler.instance)
        
        publishTrip.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            expectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        
        publishTrip.onNext(trip)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(mock.isPutCalled)
        XCTAssertNotNil(mock.dictionaryPut)
    }
    
    
    // MARK: - currentTripId
    func testTripIdNull() {
        
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor: autoModeLocationSensor, locationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        tripRecorder.rxTripId.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            expectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        
        wait(for: [expectation], timeout: 0.1)
        
    }
    
    func testCurrentTripIdNotNull() {
        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let locationSensor = LocationSensor(MockCLLocationManager())
        let autoModeLocationSensor = AutoModeLocationSensor(CLLocationManager())
        let mockLocationManager = LocationManager(autoModeLocationSensor: autoModeLocationSensor, locationSensor: locationSensor)
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
        let mockLocationManager = LocationManager(autoModeLocationSensor: autoModeLocationSensor, locationSensor: locationSensor)
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let service = TexServices.service(configuration: configuration, isTesting: true)
        
        XCTAssertNil(service.tripRecorder?.currentTripId)
    }
}



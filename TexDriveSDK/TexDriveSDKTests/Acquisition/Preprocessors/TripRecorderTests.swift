//
//  TripRecorderTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking
import CoreLocation
@testable import TexDriveSDK



class MockConfiguration : ConfigurationProtocol {
    var tripInfos: TripInfos
    
    var rxScheduler: SerialDispatchQueueScheduler {
        get {
            return MainScheduler.instance
        }
    }
    
    var rxLog = PublishSubject<LogMessage>()
    
    func log(regex: NSRegularExpression, logType: LogType) {
        
    }
    
    var tripRecorderFeatures: [TripRecorderFeature]
    let mockApiSessionManager = APISessionManagerMock()
    
    init(features: [TripRecorderFeature]) {
        tripRecorderFeatures = features
        tripInfos = TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction)
    }
    
    func generateAPISessionManager() -> APISessionManagerProtocol {
        return mockApiSessionManager
    }
}


class TripRecorderTests: XCTestCase {
    var tripRecorder: TripRecorder?
    var rxDisposeBag: DisposeBag?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        
        
        let user = User.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: Locale.current, currentUser: user, currentTripRecorderFeatures: [TripRecorderFeature]())
            
            tripRecorder = TripRecorder(config: configuration!, sessionManager: configuration!.generateAPISessionManager())
            
            let logFactory = configuration!.logFactory
            logFactory.rxLogOutput.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
                if let logDetail = event.element {
                    print(logDetail.description)
                }
                }.disposed(by: rxDisposeBag!)
        } catch {
            XCTAssert(false)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit_LocationFeatureStart() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let tripRecorder = TripRecorder(config: configuration, sessionManager: configuration.generateAPISessionManager())
        
        var locations = [CLLocation]()
        
        tripRecorder.start()
        
        for i in 0...TripConstant.MinFixesToSend {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
        }
        
        mockLocationManager.send(locations: locations)
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 5).first() {
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
        
        let tripRecorder = TripRecorder(config: configuration, sessionManager: configuration.generateAPISessionManager())
        
        var locations = [CLLocation]()
        
        tripRecorder.start()
        
        for i in 0...TripConstant.MinFixesToSend {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
        }
        mockLocationManager.send(locations: locations)
        
        tripRecorder.stop()
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 5).first() {
                XCTAssertEqual(trip.event?.eventType, EventType.stop)
            }
        } catch {
            XCTAssertFalse(true)
        }
    }
}


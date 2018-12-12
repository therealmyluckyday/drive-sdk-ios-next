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
    var rxScheduler: SerialDispatchQueueScheduler {
        get {
            return MainScheduler.asyncInstance
        }
    }
    
    var rxLog = PublishSubject<LogMessage>()
    
    func log(regex: NSRegularExpression, logType: LogType) {
        
    }
    
    var tripRecorderFeatures: [TripRecorderFeature]
    let mockApiSessionManager = APISessionManagerMock()
    
    init(features: [TripRecorderFeature]) {
        tripRecorderFeatures = features
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
            let configuration = try Config(applicationId: appId, applicationLocale: Locale.current, currentUser: user, currentMode: Mode.manual, currentTripRecorderFeatures: [TripRecorderFeature]())
            
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
    
    func testInit_LocationFeature() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        let mockLocationManager = MockLocationManager()
        let locationFeature = TripRecorderFeature.Location(mockLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        
        let tripRecorder = TripRecorder(config: configuration, sessionManager: configuration.generateAPISessionManager())
        
        var locations = [CLLocation]()
        
        tripRecorder.start()
        
        for i in 0...99 {
            let location = CLLocation(latitude: CLLocationDegrees(i), longitude: CLLocationDegrees(i))
            locations.append(location)
            
            mockLocationManager.send(locations: [location])
        }
        
        
        tripRecorder.stop()
        
        do{
            if let trip = try tripRecorder.persistantQueue.providerTrip.toBlocking(timeout: 5).first() {
                XCTAssertEqual(trip.event[0], EventType.start)
                XCTAssertEqual(trip.event[1], EventType.stop)
                XCTAssertEqual(trip.event.count, 2)
                XCTAssertEqual(trip.count, 0)
            }
        } catch {
            XCTAssertFalse(true)
        }
    }
}


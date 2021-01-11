//
//  FakeTripTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 16/09/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
import os

@testable import TexDriveSDK

class FakeTripTests: XCTestCase {
    var rxDisposeBag: DisposeBag = DisposeBag()
        
    override func setUpWithError() throws {
        self.rxDisposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFakeLocationManagerLoadTrips() {
        let fakeLocationManager = FakeLocationManager()
        fakeLocationManager.loadTrip(intervalBetweenGPSPointInSecond: 0)
    }
    
    func testTrip_Stop() {
        let fakeLocationManager = FakeLocationManager()
        let locationFeature = TripRecorderFeature.Location(fakeLocationManager)
        let features = [locationFeature]
        let configuration = MockConfiguration(features: features)
        let mockSessionManager = APITripSessionManagerMock()
        let tripRecorder = TripRecorder(configuration: configuration, sessionManager: mockSessionManager)
        let expectation = XCTestExpectation(description: #function)
    
        tripRecorder.start()
        
        tripRecorder.persistantQueue.providerTrip.asObserver().observeOn(MainScheduler.instance).subscribe { (event) in
            if let tripChunk = event.element {
                XCTAssertEqual(tripChunk.event?.eventType, EventType.stop)
                expectation.fulfill()
            }
        }.disposed(by: rxDisposeBag)
        
        fakeLocationManager.loadTrip(intervalBetweenGPSPointInSecond: 1000)
        
        tripRecorder.stop()
        
        wait(for: [expectation], timeout: 15)
    }
    
    func testTripWithFakeLocationManagerAPIV1() throws {
        //let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        let userId = "b0d84976-b1e3-4ac0-9961-b7124279a717"
        
        os_log("[FakeTripTest] userId %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(userId)")
        let user = TexUser.Authentified(userId)
        let appId = "youdrive_france_prospect"//"APP-TEST" // APIV2 "youdrive-france-prospect"
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        let scoreExpectation = XCTestExpectation(description: #function+"-Score")
        let tripExpectation = XCTestExpectation(description: #function+"-Trip")
        
        do {
            let fakeLocationManager = FakeLocationManager()
            try builder.enableTripRecorder(locationManager: fakeLocationManager)
            builder.select(platform: Platform.Production, isAPIV2: false)
            let config = builder.build()
            let service = TexServices.service(configuration: config, isTesting: true)
            service.logManager.rxLog.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
                if let logDetail = event.element {
                    os_log("[FakeTripTest] logDetail %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(logDetail.description)")
                    XCTAssert(logDetail.type != LogType.Error, "ERROR Log : "+logDetail.description)
                }
                }.disposed(by: self.rxDisposeBag)
            do {
                let regex = try NSRegularExpression(pattern: " .*.*", options: NSRegularExpression.Options.caseInsensitive)
                service.logManager.log(regex: regex, logType: LogType.Info)
            } catch {
                let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
                os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
            }
            var nbFix  = 0
            service.tripRecorder?.rxFix.asObserver().observeOn(MainScheduler.asyncInstance).subscribe({ (eventFix) in
                if let _ = eventFix.element {
                    nbFix += 1
                    if (nbFix == 935) {tripExpectation.fulfill()}
                }
                
            }).disposed(by: rxDisposeBag)
            service.tripRecorder?.tripIdFinished.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
               if let tripId = event.element {
                os_log("[FakeTripTest] tripIdFinished %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(tripId.uuidString)")
                service.scoringClient?.getScore(tripId: tripId, isAPIV2: false, completionHandler: { (result) in
                    os_log("Scoring: result %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(result)")
                    scoreExpectation.fulfill()
                })
                
                
                
               }
               }.disposed(by: rxDisposeBag)
            let dateStart = Date(timeIntervalSinceNow: -1010)
            service.tripRecorder?.start(date: dateStart)
            
            // Loading GPS Element
            fakeLocationManager.loadTrip(intervalBetweenGPSPointInSecond: 0.05)
            
            wait(for: [tripExpectation], timeout: 1570)
            
            os_log("[FakeTripTest] tripIdFinished %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(service.tripRecorder?.currentTripId!.uuidString)")
            service.tripRecorder?.stop()
            
            
        } catch ConfigurationError.LocationNotDetermined(let description) {
            os_log("[FakeTripTest] configurationError %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#function) \(description)")
        } catch {
            os_log("[FakeTripTest] error %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#file) \(#function) \(error)")
        }
        
         os_log("[FakeTripTest] trip Finished waiting for scoring %@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function)")
        wait(for: [scoreExpectation], timeout: 70)
    }
    
    
    func testTripWithFakeLocationManagerAPIV2() throws {
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        os_log("[FakeTripTest] userId %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(userId)")
        let user = TexUser.Authentified(userId)
        let appId = "youdrive-france-prospect"//"APP-TEST" // APIV2 "youdrive-france-prospect"
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: true)
        let scoreExpectation = XCTestExpectation(description: #function+"-Score")
        let tripExpectation = XCTestExpectation(description: #function+"-Trip")
        
        do {
            let fakeLocationManager = FakeLocationManager()
            try builder.enableTripRecorder(locationManager: fakeLocationManager)
            builder.select(platform: Platform.Testing, isAPIV2: true)
            let config = builder.build()
            let service = TexServices.service(configuration: config, isTesting: true)
            service.logManager.rxLog.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
                if let logDetail = event.element {
                    os_log("[FakeTripTest] logDetail %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(logDetail.description)")
                    XCTAssert(logDetail.type != LogType.Error, "ERROR Log : "+logDetail.description)
                }
                }.disposed(by: self.rxDisposeBag)
            do {
                let regex = try NSRegularExpression(pattern: " .*.*", options: NSRegularExpression.Options.caseInsensitive)
                service.logManager.log(regex: regex, logType: LogType.Info)
            } catch {
                let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
                os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
            }
            var nbFix  = 0
              service.tripRecorder?.rxFix.asObserver().observeOn(MainScheduler.asyncInstance).subscribe({ (eventFix) in
                if let _ = eventFix.element {
                    nbFix += 1
                    if (nbFix == 935) {tripExpectation.fulfill()}
                }
            }).disposed(by: rxDisposeBag)
            service.tripRecorder?.tripIdFinished.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
               if let tripId = event.element {
                os_log("Trip finished  %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function) \(tripId.uuidString)")
                service.scoringClient?.getScore(tripId: tripId, isAPIV2: true, completionHandler: { (result) in
                    switch (result) {
                    case .Success(let score):
                        os_log("%{private}@ " , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function) \(score)")
                        break
                    case .Failure(let error):
                        os_log("%{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#file) \(#function) \(error)")
                        break
                    }
                    scoreExpectation.fulfill()
                })
               }
               }.disposed(by: rxDisposeBag)
            
            service.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ (event) in
                if let score = event.element {
                    print( "\n NEW SCORE \(score)")
                    scoreExpectation.fulfill()
                }
            }).disposed(by: rxDisposeBag)
            service.tripRecorder?.start()
            
            // Loading GPS Element
            fakeLocationManager.loadTrip(intervalBetweenGPSPointInSecond: 0.05)
            
            wait(for: [tripExpectation], timeout: 570)
            let tripId = (service.tripRecorder?.currentTripId!)!
            os_log("[FakeTripTest] tripIdFinished %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function) \(service.tripRecorder?.currentTripId!.uuidString)")
            service.tripRecorder?.stop()
            
            service.scoringClient?.getScore(tripId: tripId, isAPIV2: true, completionHandler: { (result) in
                switch (result) {
                case .Success(let score):
                    os_log("%{private}@ " , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function) \(score)")
                    break
                case .Failure(let error):
                    os_log("%{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#file) \(#function) \(error)")
                    break
                }
                scoreExpectation.fulfill()
            })
            
        } catch ConfigurationError.LocationNotDetermined(let description) {
             os_log("[FakeTripTest] configurationError %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#function) \(description)")
        } catch {
            os_log("[FakeTripTest] error %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#function) \(error)")
        }
        
        os_log("%{private}@ Trip finished waiting for scoring" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function)")
        wait(for: [scoreExpectation], timeout: 120)
    }
    
    func testTripWithAutomodeAndFakeLocationManagerAPIV1() throws {
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        let user = TexUser.Authentified(userId)
        let appId = "APP-TEST"
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        let scoreExpectation = XCTestExpectation(description: #function+"-Score")
        let tripExpectation = XCTestExpectation(description: #function+"-Trip")
        
        do {
            let fakeLocationManager = FakeLocationManager()
            try builder.enableTripRecorder(locationManager: fakeLocationManager)
            builder.select(platform: Platform.Production, isAPIV2: false)
            let config = builder.build()
            let service = TexServices.service(configuration: config, isTesting: true)
            
            do {
                let regex = try NSRegularExpression(pattern: " .*.*", options: NSRegularExpression.Options.caseInsensitive)
                service.logManager.log(regex: regex, logType: LogType.Info)
            } catch {
                let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
                os_log("[ViewController][configureLog] regex error %@", log: customLog, type: .error, error.localizedDescription)
            }
            
            service.logManager.rxLog.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
                if let logDetail = event.element {
                    os_log("[FakeTripTest] logDetail %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(logDetail.description)")
                    XCTAssert(logDetail.type != LogType.Error, "ERROR Log : "+logDetail.description)
                }
                }.disposed(by: self.rxDisposeBag)
            
            var nbFix  = 0
            service.tripRecorder?.rxFix.asObserver().observeOn(MainScheduler.asyncInstance).subscribe({ (eventFix) in
                if let _ = eventFix.element {
                    nbFix += 1
                    if (nbFix == 634) {
                        os_log("%@ Fake trip loadded need to stop" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function)")
                    }
                }
            }).disposed(by: rxDisposeBag)
            service.tripRecorder?.tripIdFinished.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
               if let tripId = event.element {
                os_log("[FakeTripTest] tripIdFinished %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#function) \(tripId.uuidString)")
                tripExpectation.fulfill()
                
                service.scoringClient?.getScore(tripId: tripId, isAPIV2: false, completionHandler: { (result) in
                    switch (result) {
                    case .Success(let score):
                        os_log("%{private}@ " , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function) \(score)")
                        break
                    case .Failure(let error):
                        os_log("%{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#file) \(#function) \(error)")
                        break
                    }
                    scoreExpectation.fulfill()
                })
               }
               }.disposed(by: rxDisposeBag)
            
            service.tripRecorder?.autoMode?.rxIsDriving.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
                if let isDriving = event.element {
                    if isDriving {
                        os_log("%{private}@ Driving Start" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function)")
                        service.tripRecorder?.start()
                    } else {
                        os_log("%{private}@ Driving stop" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function)")
                        service.tripRecorder?.stop()
                    }
                }
                }.disposed(by: rxDisposeBag)
            
            service.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ (event) in
                if let score = event.element {
                    scoreExpectation.fulfill()
                }
            }).disposed(by: rxDisposeBag)
            
            service.tripRecorder?.configureAutoMode(MainScheduler.asyncInstance)
            service.tripRecorder?.activateAutoMode()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1000)) {
                os_log(" %{private}@ Loading GPS element" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function)")
                fakeLocationManager.loadTrip(intervalBetweenGPSPointInSecond: 1.05)
            }
            wait(for: [tripExpectation], timeout: 70)
        } catch ConfigurationError.LocationNotDetermined(let description) {
             os_log("[FakeTripTest] configurationError %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#function) \(description)")
        } catch {
            os_log("[FakeTripTest] error %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.error, "\(#function) \(error)")
        }
        os_log("%{private}@ Trip finished waiting for scoring" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(#file) \(#function)")
        wait(for: [scoreExpectation], timeout: 70)
    }
}

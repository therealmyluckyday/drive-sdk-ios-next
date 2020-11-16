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
        fakeLocationManager.loadTrip(intervalBetweenGPSPointInMilliSecond: 0)
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
        
        fakeLocationManager.loadTrip(intervalBetweenGPSPointInMilliSecond: 1000)
        
        tripRecorder.stop()
        
        wait(for: [expectation], timeout: 15)
    }
    
    func testFakeSensorService() throws {
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        print(userId)
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
                    print(logDetail.description)
                    XCTAssert(logDetail.type != LogType.Error, "ERROR Log : "+logDetail.description)
                    print(logDetail.description)
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
                   print("\n Trip finished: \n \(tripId.uuidString)")
               }
               }.disposed(by: rxDisposeBag)
            service.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ (event) in
                if let score = event.element {
                    print( "\n NEW SCORE \(score)")
                    scoreExpectation.fulfill()
                }
            }).disposed(by: rxDisposeBag)
            service.tripRecorder!.start()
            
            // Loading GPS Element
            fakeLocationManager.loadTrip(intervalBetweenGPSPointInMilliSecond: 1000)
            
            wait(for: [tripExpectation], timeout: 570)
            
            print("\n Trip finished: \n \(service.tripRecorder?.currentTripId?.uuidString)")
            service.tripRecorder!.stop()
            
            
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print("\n ConfigurationError : \(description)")
        } catch {
            print("\n ERROR : \(error)")
        }
        
        print("Trip Finished Waiting for Scoring")
        wait(for: [scoreExpectation], timeout: 70)
    }
    
    
    func testFakeSensorServiceAPIV2() throws {
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        print(userId)
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
                    print(logDetail.description)
                    XCTAssert(logDetail.type != LogType.Error, "ERROR Log : "+logDetail.description)
                    print(logDetail.description)
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
                   print("\n Trip finished: \n \(tripId.uuidString)")
                service.scoringClient!.getScore(tripId: tripId, isAPIV2: true, completionHandler: { (result) in
                    switch (result) {
                    case .Success(let score):
                        print(score)
                        break
                    case .Failure(let error):
                        print(error)
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
            service.tripRecorder!.start()
            
            // Loading GPS Element
            fakeLocationManager.loadTrip(intervalBetweenGPSPointInMilliSecond: 1000)
            
            wait(for: [tripExpectation], timeout: 570)
            let tripId = service.tripRecorder!.currentTripId!
            print("\n Trip finished: \n \(service.tripRecorder?.currentTripId?.uuidString)")
            service.tripRecorder!.stop()
            
            service.scoringClient!.getScore(tripId: tripId, isAPIV2: true, completionHandler: { (result) in
                switch (result) {
                case .Success(let score):
                    print(score)
                    break
                case .Failure(let error):
                    print(error)
                    break
                }
                scoreExpectation.fulfill()
            })
            
            
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print("\n ConfigurationError : \(description)")
        } catch {
            print("\n ERROR : \(error)")
        }
        
        print("Trip Finished Waiting for Scoring")
        wait(for: [scoreExpectation], timeout: 120)
    }
    
    func testAutomodeWithFakeSensorService() throws {
        let userId = "Erwan-"+UIDevice.current.systemName + UIDevice.current.systemVersion
        let user = TexUser.Authentified(userId)
        let appId = "APP-TEST"
        let builder = TexConfigBuilder(appId: appId, texUser: user, isAPIV2: false)
        let scoreExpectation = XCTestExpectation(description: #function+"-Score")
        let tripExpectation = XCTestExpectation(description: #function+"-Trip")
        
        var date = Date()
        
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
                    print("LOG \(logDetail.description)")
                    XCTAssert(logDetail.type != LogType.Error, "ERROR Log : "+logDetail.description)
                }
                }.disposed(by: self.rxDisposeBag)
            
            var nbFix  = 0
            service.tripRecorder!.rxFix.asObserver().observeOn(MainScheduler.asyncInstance).subscribe({ (eventFix) in
                if let _ = eventFix.element {
                    nbFix += 1
                    if (nbFix == 634) {
                        print("\n [\(Date())]  Fake Trip loaded NEED TO STOP")
                    }
                }
            }).disposed(by: rxDisposeBag)
            service.tripRecorder!.tripIdFinished.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
               if let tripId = event.element {
                date = Date()
                   print("\n [\(date)]  Trip finished: \n \(tripId.uuidString)")
                   tripExpectation.fulfill()
               }
               }.disposed(by: rxDisposeBag)
            
            service.tripRecorder!.autoMode!.rxIsDriving.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
                if let isDriving = event.element {
                    date = Date()
                    if isDriving {
                        print("[\(date)] DRIVING START")
                    } else {
                        print("[\(date)] DRIVING STOP")
                    }
                }
                }.disposed(by: rxDisposeBag)
            
            service.rxScore.asObserver().observeOn(MainScheduler.asyncInstance).retry().subscribe({ (event) in
                if let score = event.element {
                    date = Date()
                    print( "\n [\(date)]  NEW SCORE \(score)")
                    scoreExpectation.fulfill()
                }
            }).disposed(by: rxDisposeBag)
            
            service.tripRecorder!.configureAutoMode(MainScheduler.asyncInstance)
            service.tripRecorder!.activateAutoMode()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 1000)) {
                date = Date()
                print("[\(date)] Loading GPS Element")
                fakeLocationManager.loadTrip(intervalBetweenGPSPointInMilliSecond: 1000)
            }
            wait(for: [tripExpectation], timeout: 70)
            
        } catch ConfigurationError.LocationNotDetermined(let description) {
            print("\n ConfigurationError : \(description)")
        } catch {
            print("\n ERROR : \(error)")
        }
        date = Date()
        print("[\(date)] Trip Finished Waiting for Scoring")
        wait(for: [scoreExpectation], timeout: 70)
    }
}

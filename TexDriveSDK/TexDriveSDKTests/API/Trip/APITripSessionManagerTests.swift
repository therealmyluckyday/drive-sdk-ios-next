//
//  APITripSessionManagerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest
import RxSwift
@testable import TexDriveSDK

class APITripSessionManagerTests: XCTestCase {
    var apiSessionManager: APITripSessionManager?
    var rxDisposeBag: DisposeBag?
    let logFactory = LogRx()
    var urlBackgroundTaskSession: URLSession?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = TexUser.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForResource = 5
        apiSessionManager = APITripSessionManager(configuration: TripInfos(appId: appId, user: user, domain: Platform.Preproduction, isAPIV2: false), urlSessionConfiguration: urlSessionConfiguration)
        #if targetEnvironment(simulator)
        let config = URLSessionConfiguration.default
        #else
        let config = URLSessionConfiguration.background(withIdentifier: "TexSession")
        #endif
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        urlBackgroundTaskSession = URLSession(configuration: config, delegate: apiSessionManager, delegateQueue: nil)
    }
    
    override func tearDown() {
        rxDisposeBag = nil
        super.tearDown()
    }
    
    // MARK: - func isTripStoppedSend(task: URLSessionDownloadTask) -> Bool
    func testIsTripStopped_true() {
        let eventType = EventType.stop
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: TexUser.Anonymous, domain: Platform.Preproduction, isAPIV2: false))
        tripChunk.append(eventType: eventType)
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT, withCompression: true) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertTrue(APITripSessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    func testIsTripStopped_false_NoStopEvent() {
        let eventType = EventType.start
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: TexUser.Anonymous, domain: Platform.Preproduction, isAPIV2: false))
        tripChunk.append(eventType: eventType)
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertFalse(APITripSessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    
    func testIsTripStopped_false_noEvent() {
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: TexUser.Anonymous, domain: Platform.Preproduction, isAPIV2: false))
        tripChunk.append(fix: LocationFix(timestamp: 0, latitude: 0, longitude: 0, precision: 0, speed: 0, bearing: 0, altitude: 0, distance: 1))
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertFalse(APITripSessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    
    func testIsTripStopped_false_emptyBody() {
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: [String: Any](), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertFalse(APITripSessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    
    func testIsTripStopped_false_nojsonBody() {
        var request = URLRequest(url: URL(string: "http://google.com")!)
        request.httpBody = Data(_: [15])
        let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
        XCTAssertFalse(APITripSessionManager.isTripStoppedSend(task: backgroundTask))
    }
    
    // MARK: - func getTripId(task: URLSessionDownloadTask) -> TripId
    func testGetTripId() {
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: TexUser.Anonymous, domain: Platform.Preproduction, isAPIV2: false))
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            let tripIdResult = APITripSessionManager.getTripId(task: backgroundTask)
            XCTAssertNotNil(tripIdResult)
            XCTAssertEqual(tripIdResult!.uuidString, tripChunk.tripId.uuidString)
        }
        else {
            XCTAssertTrue(false)
        }
    }

}

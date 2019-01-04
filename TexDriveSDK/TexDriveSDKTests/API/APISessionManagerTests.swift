//
//  APISessionManagerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
@testable import TexDriveSDK

class APISessionManagerMock: APISessionManagerProtocol {
    func get(parameters: [String : Any], completionHandler: @escaping (Result<[String : Any]>) -> ()) {
    }
    
    var isPutCalled = false
    var dictionaryPut : [String: Any]?
    func put(dictionaryBody: [String: Any]) {
        isPutCalled = true
        dictionaryPut = dictionaryBody
    }
}

class APISessionManagerTests: XCTestCase {
    var apiSessionManager: APISessionManager?
    var rxDisposeBag: DisposeBag?
    let logFactory = LogRx()
    var urlBackgroundTaskSession: URLSession?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = User.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        apiSessionManager = APISessionManager(configuration: TripInfos(appId: appId, user: user, domain: Domain.Preproduction))
        let config = URLSessionConfiguration.background(withIdentifier: "TexSession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        urlBackgroundTaskSession = URLSession(configuration: config, delegate: apiSessionManager, delegateQueue: nil)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    // func get(parameters: [String: Any], completionHandler: @escaping (Result<[String: Any]>) -> ())
    func testGetSuccess() {
        var isCompleted = false
        let tripId = "73B1C1B6-8DD8-4DEA-ACAF-4B1E05F6EF09"
        let getSuccessExpected = self.expectation(description: "testGetSuccessExpectation")
        let dictionary = ["trip_id":tripId, "lang": Locale.current.identifier]
        apiSessionManager!.get(parameters: dictionary) { (result) in
            switch result {
            case Result.Success(let response):
                let score = Score(dictionary: response)
                XCTAssertNotNil(score)
                break
            default:
                XCTAssert(false)
            }
            isCompleted = true
            getSuccessExpected.fulfill()
            
        }
        wait(for: [getSuccessExpected], timeout: 5)
        XCTAssertTrue(isCompleted)
    }
    
    func testGetError() {
        var isCompleted = false
        let getSuccessExpected = self.expectation(description: "testGetFailureExpectation")
        let dictionary = [String: Any]()
        apiSessionManager!.get(parameters: dictionary) { (result) in
            switch result {
            case Result.Success(_):
                XCTAssert(false)
                break
            case Result.Failure(let error as APIError):
                XCTAssertEqual(error.statusCode, 400)
            case .Failure(_):
                XCTAssert(false)
            }
            isCompleted = true
            getSuccessExpected.fulfill()
            
        }
        wait(for: [getSuccessExpected], timeout: 5)
        XCTAssertTrue(isCompleted)
    }
    
    // MARK : func isTripStoppedSend(task: URLSessionDownloadTask) -> Bool
    func testIsTripStopped_true() {
        let eventType = EventType.stop
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: User.Anonymous, domain: Domain.Preproduction))
        tripChunk.append(eventType: eventType)
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertTrue(APISessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    func testIsTripStopped_false_NoStopEvent() {
        let eventType = EventType.start
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: User.Anonymous, domain: Domain.Preproduction))
        tripChunk.append(eventType: eventType)
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertFalse(APISessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    
    func testIsTripStopped_false_noEvent() {
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: User.Anonymous, domain: Domain.Preproduction))
        tripChunk.append(fix: LocationFix(timestamp: 0, latitude: 0, longitude: 0, precision: 0, speed: 0, bearing: 0, altitude: 0))
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertFalse(APISessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    
    func testIsTripStopped_false_emptyBody() {
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: [String: Any](), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            XCTAssertFalse(APISessionManager.isTripStoppedSend(task: backgroundTask))
        }
        else {
            XCTAssertTrue(false)
        }
    }
    
    func testIsTripStopped_false_nojsonBody() {
        var request = URLRequest(url: URL(string: "http://google.com")!)
        request.httpBody = Data(bytes: [15])
        let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
        XCTAssertFalse(APISessionManager.isTripStoppedSend(task: backgroundTask))
    }
    
    // MARK : func getTripId(task: URLSessionDownloadTask) -> TripId
    func testGetTripId() {
        let tripChunk = TripChunk(tripInfos: TripInfos(appId: "TEST", user: User.Anonymous, domain: Domain.Preproduction))
        print(tripChunk.serialize())
        if let request = URLRequest.createUrlRequest(url: URL(string: "http://google.com")!, body: tripChunk.serialize(), httpMethod: HttpMethod.PUT) {
            let backgroundTask = urlBackgroundTaskSession!.downloadTask(with: request)
            let tripIdResult = APISessionManager.getTripId(task: backgroundTask)
            XCTAssertNotNil(tripIdResult)
            print(tripChunk.tripId.uuidString)
            print(tripIdResult!.uuidString)
            XCTAssertEqual(tripIdResult!.uuidString, tripChunk.tripId.uuidString)
        }
        else {
            XCTAssertTrue(false)
        }
    }
}



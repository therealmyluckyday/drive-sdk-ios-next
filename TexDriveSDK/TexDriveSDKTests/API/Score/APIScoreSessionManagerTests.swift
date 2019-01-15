//
//  APIScoreSessionManagerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
@testable import TexDriveSDK

class APIScoreSessionManagerTests: XCTestCase {
    var apiSessionManager: APIScoreSessionManager?
    var rxDisposeBag: DisposeBag?
    let logFactory = LogRx()
    var urlBackgroundTaskSession: URLSession?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = User.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        apiSessionManager = APIScoreSessionManager(configuration: TripInfos(appId: appId, user: user, domain: Domain.Preproduction))
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
}



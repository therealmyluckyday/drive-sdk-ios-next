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
class MockAPIScoreSessionManager: APIScoreSessionManager {
    var retryExpected: XCTestExpectation?
    override func retry(request: URLRequest, completionHandler: @escaping (Result<[String : Any]>) -> ()) {
        DispatchQueue.main.async {
            self.retryExpected?.fulfill()
        }
    }
}
class APIScoreSessionManagerTests: XCTestCase {
    var apiSessionManager: MockAPIScoreSessionManager?
    var rxDisposeBag: DisposeBag?
    let logFactory = LogRx()
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = TexUser.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        apiSessionManager = MockAPIScoreSessionManager(configuration: TripInfos(appId: appId, user: user, domain: Platform.Preproduction, isAPIV2: false))
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
        wait(for: [getSuccessExpected], timeout: 1)
        XCTAssertTrue(isCompleted)
    }
    
    func testGetErrorRetry() {
        let retryExpected = self.expectation(description: "testGetFailureRetryExpectation")
        apiSessionManager!.retryExpected = retryExpected
        let dictionary = [String: Any]()
        
        apiSessionManager!.get(parameters: dictionary) { (result) in
            switch result {
            case Result.Success(_):
                XCTAssert(false)
                break
            case .Failure(_):
                XCTAssert(false)
            }
        }
        wait(for: [retryExpected], timeout: 1)
    }
}



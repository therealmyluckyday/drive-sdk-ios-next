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

class APISessionManagerTests: XCTestCase {
    var apiSessionManager: APISessionManager?
    var rxDisposeBag: DisposeBag?
    let logFactory = LogRxFactory()
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = User.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        apiSessionManager = APISessionManager(configuration: TripInfos(appId: appId, user: user, domain: Domain.Preproduction))
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    // func get(parameters: [String: Any], completionHandler: @escaping (Result<[String: Any]>) -> ())
    func testGetSuccess() {
        var isCompleted = false
        let tripId = "461105AE-A712-41A7-939C-4982413BE30F1543910782.13927"
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



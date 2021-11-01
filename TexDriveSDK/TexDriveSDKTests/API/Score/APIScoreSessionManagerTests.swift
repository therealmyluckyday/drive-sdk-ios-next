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
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForResource = 5
        apiSessionManager = MockAPIScoreSessionManager(configuration: TripInfos(appId: appId, user: user, domain: Platform.Preproduction, isAPIV2: false), urlSessionConfiguration: urlSessionConfiguration)
    }
    
    override func tearDown() {
        
        super.tearDown()
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
        wait(for: [retryExpected], timeout: 10)
    }
}



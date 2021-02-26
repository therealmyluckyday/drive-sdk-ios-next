//
//  APITripTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 14/11/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift


@testable import TexDriveSDK
class APITripSessionManagerMock: APITripSessionManagerProtocol {
    func put(body: String, baseUrl: String) {
        // Only use for Background task
    }
    
    var tripIdFinished = PublishSubject<TripId>()
    
    var tripChunkSent = PublishSubject<Result<TripId>>()
    var baseUrl = ""
    
    func get(parameters: [String : Any], completionHandler: @escaping (Result<[String : Any]>) -> ()) {
    }
    
    var isPutCalled = false
    var dictionaryPut : [String: Any]?
    func put(dictionaryBody: [String: Any], baseUrl: String) {
        isPutCalled = true
        dictionaryPut = dictionaryBody
        self.baseUrl = baseUrl
    }
}

class APITripTests: XCTestCase {
    // MARK: func subscribe(providerTrip: PublishSubject<Trip>)
    func testSubscribe() {
        let mock = APITripSessionManagerMock()
        
        let apiTrip = APITrip(apiSessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Integration, isAPIV2: false))
        
        apiTrip.sendTrip(trip: trip)
        
        XCTAssertTrue(mock.isPutCalled)
        XCTAssertNotNil(mock.dictionaryPut)
    }
}

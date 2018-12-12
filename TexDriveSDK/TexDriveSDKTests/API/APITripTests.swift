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
import RxTest


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

class APITripTests: XCTestCase {
    // MARK: func subscribe(providerTrip: PublishSubject<Trip>)
    func testSubscribe() {
        let publishTrip = PublishSubject<TripChunk>()
        let mock = APISessionManagerMock()
        let apiTrip = APITrip(apiSessionManager: mock)
        let tripId = "tripId"
        let trip = TripChunk(tripId: tripId)
        apiTrip.subscribe(providerTrip: publishTrip, scheduler: MainScheduler.instance)
        publishTrip.onNext(trip)
        
        XCTAssertTrue(mock.isPutCalled)
        XCTAssertNotNil(mock.dictionaryPut)
    }
}

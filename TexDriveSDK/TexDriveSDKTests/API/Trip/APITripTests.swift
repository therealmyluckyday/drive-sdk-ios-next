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
class APITripSessionManagerMock: APITripSessionManagerProtocol {
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
        let mock = APITripSessionManagerMock()
        
        let apiTrip = APITrip(apiSessionManager: mock)
        let trip = TripChunk(tripInfos: TripInfos(appId: "youdrive_france_prospect", user: User.Authentified("Erwan-ios12"), domain: Domain.Preproduction))
        
        apiTrip.sendTrip(trip: trip)
        
        XCTAssertTrue(mock.isPutCalled)
        XCTAssertNotNil(mock.dictionaryPut)
    }
}

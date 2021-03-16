//
//  ScoreRetrieverTest.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift

@testable import TexDriveSDK

class ScoreRetrieverTest: XCTestCase {
    var rxDisposeBag: DisposeBag?
    var scoreRetriever: ScoreRetriever?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = TexUser.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        
        let urlScoreSessionConfiguration = URLSessionConfiguration.default
        urlScoreSessionConfiguration.timeoutIntervalForResource = 5
        let configuration = TexConfig(applicationId: appId, currentUser: user, isAPIV2: false)
        configuration.select(domain: Platform.Preproduction, isAPIV2: false)
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos, urlSessionConfiguration: urlScoreSessionConfiguration)
        scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: Locale.current)

    }
    
    

    func testGetScoreV1() {
        let tripId = TripId(uuidString: "73B1C1B6-8DD8-4DEA-ACAF-4B1E05F6EF09")!
        let duration = Double(698)
        let distance = 2.6
        let startTime = Double(1545382379)
        let endTime = Double(1545383077)
        let scoreExpected = ScoreV1(tripId:tripId,  global: 86.07, speed: 100, acceleration: 62.15, braking: 82.11, smoothness: 100, startDouble:startTime, endDouble: endTime, distance: distance, duration: duration)
        let expectation = self.expectation(description: "APIGetScoreCalled")
        let rxScore = PublishSubject<Score>()
        rxScore.asObserver().observe(on: MainScheduler.asyncInstance).subscribe { (event) in
            if let score = event.element as? ScoreV1{
                expectation.fulfill()
                XCTAssertEqual(scoreExpected.global, score.global)
                XCTAssertEqual(scoreExpected.speed, score.speed)
                XCTAssertEqual(scoreExpected.acceleration, score.acceleration)
                XCTAssertEqual(scoreExpected.braking, score.braking)
                XCTAssertEqual(scoreExpected.smoothness, score.smoothness)
            }
            else {
                XCTAssertTrue(false)
            }
            }.disposed(by: rxDisposeBag!)
        
        scoreRetriever!.getScore(tripId: tripId, isAPIV2: false, rxScore: rxScore)
        wait(for: [expectation], timeout: 1)
    }
}

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
        
        let configuration = TexConfig(applicationId: appId, currentUser: user)
        configuration.select(domain: Platform.Preproduction)
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos)
        scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: Locale.current)

    }
    
    

    func testGetScore() {
        let tripId = TripId(uuidString: "73B1C1B6-8DD8-4DEA-ACAF-4B1E05F6EF09")!
        let scoreExpected = Score(tripId:tripId,  global: 86.07, speed: 100, acceleration: 62.15, braking: 82.11, smoothness: 100)
        let expectation = self.expectation(description: "APIGetScoreCalled")
        let rxScore = PublishSubject<Score>()
        
        rxScore.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
            if let score = event.element {
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
        
        scoreRetriever!.getScore(tripId: tripId, rxScore: rxScore)
        wait(for: [expectation], timeout: 5)
    }
}

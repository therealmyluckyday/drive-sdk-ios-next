//
//  ScoringClientTest.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift

@testable import TexDriveSDK

class ScoringClientTest: XCTestCase {
    var rxDisposeBag: DisposeBag?
    var scoringClient: ScoringClient?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let user = User.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: Locale.current, currentUser: user, currentTripRecorderFeatures: [TripRecorderFeature]())
            scoringClient = ScoringClient(sessionManager: configuration!.generateAPISessionManager(), locale: Locale.current)
        } catch {
            XCTAssert(false)
        }
    }
    
    

    func testGetScore() {
        let tripId = NSUUID(uuidString: "73B1C1B6-8DD8-4DEA-ACAF-4B1E05F6EF09")!
        var isCompletionCalled = false
        let scoreExpected = Score(tripId:tripId,  global: 86.07, speed: 100, acceleration: 62.15, braking: 82.11, smoothness: 100)
        let expectation = self.expectation(description: "APIGetScoreCalled")
        let rxScore = PublishSubject<Score>()
        
        rxScore.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
            if let score = event.element {
                isCompletionCalled = true
                XCTAssertEqual(scoreExpected.global, score.global)
                XCTAssertEqual(scoreExpected.speed, score.speed)
                XCTAssertEqual(scoreExpected.acceleration, score.acceleration)
                XCTAssertEqual(scoreExpected.braking, score.braking)
                XCTAssertEqual(scoreExpected.smoothness, score.smoothness)
            }
            else {
                XCTAssertTrue(false)
            }
            expectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        
        scoringClient!.getScore(tripId: tripId, rxScore: rxScore)
        wait(for: [expectation], timeout: 50)
        
        XCTAssertTrue(isCompletionCalled)
    }
}

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
    var disposeBag: DisposeBag?
    var scoringClient: ScoringClient?
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        let user = User.Authentified("Erwan-ios12")
        let appId = "youdrive_france_prospect"
        
        do {
            let configuration = try Config(applicationId: appId, applicationLocale: Locale.current, currentUser: user, currentMode: Mode.manual, currentTripRecorderFeatures: [TripRecorderFeature]())
            scoringClient = ScoringClient(sessionManager: configuration!.generateAPISessionManager())
        } catch {
            XCTAssert(false)
        }
    }
    
    

    func testGetScore() {
        let tripId = "461105AE-A712-41A7-939C-4982413BE30F1543910782.13927"
        var isCompletionCalled = false
        let scoreExpected = Score(tripId:tripId,  global: 75.33, speed: 100, acceleration: 49.39, braking: 53.01, smoothness: 98.9)
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
            }.disposed(by: disposeBag!)
        
        scoringClient!.getScore(tripId: tripId, rxScore: rxScore)
        wait(for: [expectation], timeout: 50)
        
        XCTAssertTrue(isCompletionCalled)
    }
}

//
//  APIScoreTest.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 03/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import RxSwift
@testable import TexDriveSDK

class APIScoreTest: XCTestCase {
    var rxDisposeBag: DisposeBag?
    var apiScore: APIScore?
    
    override func setUp() {
        super.setUp()
        rxDisposeBag = DisposeBag()
        let apiSessionManager = APIScoreSessionManager(configuration: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction, isAPIV2: false))
        
        apiScore = APIScore(apiSessionManager: apiSessionManager, locale: Locale.current)
    }
    
    override func tearDown() {
        rxDisposeBag = nil
        super.tearDown()
    }
    
    func testInit() {
        let apiSessionManager = APIScoreSessionManager(configuration: TripInfos(appId: "youdrive_france_prospect", user: TexUser.Authentified("Erwan-ios12"), domain: Platform.Preproduction, isAPIV2: false))
        apiScore = APIScore(apiSessionManager: apiSessionManager, locale: Locale.current)
    }
    
    func testGetScore_Rx_Success() {
        let tripId = TripId(uuidString: "73B1C1B6-8DD8-4DEA-ACAF-4B1E05F6EF09")!
        let duration = Double(698)
        let distance = 6.27
        let startTime = Double(1545382379000)
        let endTime = Double(1545383077000)
        let scoreExpected = Score(tripId:tripId,  global: 86.07, speed: 100, acceleration: 62.15, braking: 82.11, smoothness: 100, startDouble:startTime, endDouble: endTime, distance: distance, duration: duration)
        var isCompletionCalled = false

        let expectation = self.expectation(description: "APIGetScoreCalled")
        let rxScore = PublishSubject<Score>()
        rxScore.asObserver().observeOn(MainScheduler.asyncInstance).subscribe { (event) in
            isCompletionCalled = true
            if let score = event.element {
                XCTAssertEqual(scoreExpected.global, score.global)
                XCTAssertEqual(scoreExpected.speed, score.speed)
                XCTAssertEqual(scoreExpected.acceleration, score.acceleration)
                XCTAssertEqual(scoreExpected.braking, score.braking)
                XCTAssertEqual(scoreExpected.smoothness, score.smoothness)
                XCTAssertEqual(scoreExpected.duration , score.duration)
                XCTAssertEqual(scoreExpected.distance, score.distance)
                XCTAssertEqual(scoreExpected.startDate, score.startDate, "\(scoreExpected.startDate) \(score.startDate)")
                XCTAssertEqual(scoreExpected.endDate, score.endDate, "\(scoreExpected.endDate) \(score.endDate)")
            }
            else {
                XCTAssertTrue(false)
            }
            expectation.fulfill()
            }.disposed(by: rxDisposeBag!)
        
        apiScore!.getScore(tripId: tripId, rxScore: rxScore)
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(isCompletionCalled)
    }
    
    // MARK: - func getScore(tripId: TripId, completionHandler: @escaping (Result<Score>) -> ())
    func testGetScore_Error_not_enough_locations() {
        let tripId = TripId(uuidString: "3FECE4EA-CBBE-4463-AA24-2F6657D09962")!
        var isCompletionCalled = false
        let expectation = self.expectation(description: "APIGetScoreCalled")
        
        self.apiScore!.getScore(tripId: tripId, completionHandler: { (result) in
            switch result {
            case Result.Success(_):
                XCTAssertTrue(false)
                break
            case Result.Failure(let error):
                if let scoreError = error as? ScoreError {
                    XCTAssertEqual(scoreError.status, ScoreStatus.tooShort)
                    XCTAssertEqual(scoreError.tripId, tripId)
                    XCTAssertEqual(scoreError.details.first, ExceptionScoreStatus.lowPrecisionTrip)
                }
                else {
                    XCTAssertTrue(false)
                }
                break
            }
            isCompletionCalled = true
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(isCompletionCalled)
    }
    
    func testGetScore_Success() {
        let tripId = TripId(uuidString: "73B1C1B6-8DD8-4DEA-ACAF-4B1E05F6EF09")!
        var isCompletionCalled = false
        let duration = Double(698)
        let distance = 6.27
        let startTime = Double(1545382379000)
        let endTime = Double(1545383077000)
        let scoreExpected = Score(tripId:tripId,  global: 86.07, speed: 100, acceleration: 62.15, braking: 82.11, smoothness: 100, startDouble:startTime, endDouble: endTime, distance: distance, duration: duration)

        let expectation = self.expectation(description: "APIGetScoreCalled")
        
        self.apiScore!.getScore(tripId: tripId, completionHandler: { (result) in
            switch result {
            case Result.Success(let score):
                XCTAssertEqual(scoreExpected.global, score.global)
                XCTAssertEqual(scoreExpected.speed, score.speed)
                XCTAssertEqual(scoreExpected.acceleration, score.acceleration)
                XCTAssertEqual(scoreExpected.braking, score.braking)
                XCTAssertEqual(scoreExpected.smoothness, score.smoothness)
                XCTAssertEqual(scoreExpected.duration , score.duration)
                XCTAssertEqual(scoreExpected.distance, score.distance)
                XCTAssertEqual(scoreExpected.startDate, score.startDate)
                XCTAssertEqual(scoreExpected.endDate, score.endDate)
                break
            case Result.Failure(_):
                XCTAssertTrue(false)
                break
            }
            isCompletionCalled = true
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(isCompletionCalled)
    }
}



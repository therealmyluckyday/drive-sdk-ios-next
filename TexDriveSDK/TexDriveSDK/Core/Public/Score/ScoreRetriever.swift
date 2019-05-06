//
//  scoreRetriever.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 03/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

public protocol ScoringClient {
    func getScore(tripId: TripId, completionHandler: @escaping (Result<Score>) -> ())
    func getScore(tripId: TripId, rxScore: PublishSubject<Score>)
}

public class ScoreRetriever: ScoringClient {
    let apiScore: APIScoreProtocol
    
    init(sessionManager: APIScoreSessionManagerProtocol, locale: Locale) {
        apiScore = APIScore(apiSessionManager: sessionManager, locale: locale)
    }
    
    // MARK: - scoreRetrieverProtocol
    public func getScore(tripId: TripId, completionHandler: @escaping (Result<Score>) -> ()) {
        apiScore.getScore(tripId: tripId, completionHandler: completionHandler)
    }
    
    public func getScore(tripId: TripId, rxScore: PublishSubject<Score>) {
        apiScore.getScore(tripId: tripId, rxScore: rxScore)
    }
}

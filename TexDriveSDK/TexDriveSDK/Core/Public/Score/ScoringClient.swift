//
//  ScoringClient.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 03/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

public protocol ScoringClientProtocol {
    func getScore(tripId: String, completionHandler: @escaping (Result<Score>) -> ())
    func getScore(tripId: String, rxScore: PublishSubject<Score>)
}

public class ScoringClient: ScoringClientProtocol {
    let apiScore: APIScoreProtocol
    
    init(sessionManager: APISessionManagerProtocol) {
        apiScore = APIScore(apiSessionManager: sessionManager)
    }
    
    // MARK : SoringClientProtocol
    @available(*, deprecated, message: "Please use getScore(tripId: String, rxScore: PublishSubject<Score>)")
    public func getScore(tripId: String, completionHandler: @escaping (Result<Score>) -> ()) {
        apiScore.getScore(tripId: tripId, completionHandler: completionHandler)
    }
    
    public func getScore(tripId: String, rxScore: PublishSubject<Score>) {
        apiScore.getScore(tripId: tripId, rxScore: rxScore)
    }
}

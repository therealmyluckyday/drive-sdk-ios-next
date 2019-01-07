//
//  APIScore.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 03/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

protocol APIScoreProtocol {
    init(apiSessionManager: APISessionManagerProtocol, locale: Locale)
    func getScore(tripId: TripId, rxScore: PublishSubject<Score>)
    func getScore(tripId: TripId, completionHandler: @escaping (Result<Score>) -> ())
}


class APIScore: APIScoreProtocol {
    // MARK: Property
    private let rxDisposeBag = DisposeBag()
    private let sessionManager : APISessionManagerProtocol
    private let locale: Locale
    
    
    // MARK: APITripProtocol Protocol Method
    required init(apiSessionManager: APISessionManagerProtocol, locale: Locale) {
        self.sessionManager = apiSessionManager
        self.locale = locale
    }
    
    // MARK : APIScoreProtocol
    func getScore(tripId: TripId, rxScore: PublishSubject<Score>) {
        self.getScore(tripId: tripId, completionHandler: { (result) in
            switch result {
            case Result.Success(let score):
                rxScore.onNext(score)
                break
            case Result.Failure(let error):
                rxScore.onError(error)
                break
            }
        })
    }
    
    func getScore(tripId: TripId, completionHandler: @escaping (Result<Score>) -> ()) {
        let dictionary = ["trip_id":tripId.uuidString, "lang": Locale.current.identifier]
        
        self.sessionManager.get(parameters: dictionary) { (result) in
            switch result {
            case Result.Success(let dictionaryResult):
                if let statusString = dictionaryResult["status"] as? String,
                    let status = ScoreStatus.init(rawValue: statusString), status == ScoreStatus.ok {
                    if let score = Score(dictionary: dictionaryResult) {
                        completionHandler(Result.Success(score))
                    }
                    else {
                        let error: Error = ParsingError()
                        Log.print("Error On Parsing -\(dictionaryResult)-", type: LogType.Error)
                        completionHandler(Result.Failure(error))
                    }
                }
                else {
                    var error: Error = ParsingError()
                    if let scoreError = ScoreError(dictionary: dictionaryResult) {
                        error = scoreError
                        Log.print("Error On Score -\(dictionaryResult)-", type: LogType.Error)
                    }
                    else {
                        Log.print("Error On Parsing -\(dictionaryResult)-", type: LogType.Error)
                    }
                    completionHandler(Result.Failure(error))
                }
                break
            case Result.Failure(let error):
                completionHandler(Result.Failure(error))
                break
            }
        }
    }
}

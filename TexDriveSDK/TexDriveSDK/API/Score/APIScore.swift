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
    init(apiSessionManager: APIScoreSessionManagerProtocol, locale: Locale)
    func getScore(tripId: TripId, isAPIV2: Bool, rxScore: PublishSubject<Score>)
    func getScore(tripId: TripId, isAPIV2: Bool, completionHandler: @escaping (Result<Score>) -> ())
}


class APIScore: APIScoreProtocol {
    // MARK: Property
    private let rxDisposeBag = DisposeBag()
    private let sessionManager : APIScoreSessionManagerProtocol
    private let locale: Locale
    
    
    // MARK: APITripProtocol Protocol Method
    required init(apiSessionManager: APIScoreSessionManagerProtocol, locale: Locale) {
        self.sessionManager = apiSessionManager
        self.locale = locale
    }
    
    // MARK: - APIScoreProtocol
    func getScore(tripId: TripId, isAPIV2: Bool, rxScore: PublishSubject<Score>) {
        self.getScore(tripId: tripId, isAPIV2: isAPIV2, completionHandler: { (result) in
            switch result {
            case Result.Success(let score):
                rxScore.onNext(score)
                break
            case Result.Failure(let error):
                Log.print("\(error)", type: .Error)
                break
            }
        })
    }
    
    func getScore(tripId: TripId, isAPIV2: Bool, completionHandler: @escaping (Result<Score>) -> ()) {
        let dictionary = ["trip_id":tripId.uuidString, "lang": Locale.current.identifier]
        
        self.sessionManager.get(parameters: dictionary, isAPIV2: isAPIV2) { (result) in
            switch result {
            case Result.Success(let dictionaryResult):
                if let statusString = dictionaryResult["status"] as? String,
                    let status = ScoreStatus.init(rawValue: statusString){
                    switch status {
                    
                    case .found, .notFound:
                        print("SCOREV2")
                        if let score = ScoreV2(dictionary: dictionaryResult) {
                            completionHandler(Result.Success(score))
                        }
                        else {
                            let error: Error = ParseError()
                            Log.print("Error On Parsing -\(dictionaryResult)-", type: LogType.Error)
                            completionHandler(Result.Failure(error))
                        }
                        
                            break
                    case .ok:
                        if let score = ScoreV1(dictionary: dictionaryResult) {
                            completionHandler(Result.Success(score))
                        }
                        else {
                            let error: Error = ParseError()
                            Log.print("Error On Parsing -\(dictionaryResult)-", type: LogType.Error)
                            completionHandler(Result.Failure(error))
                        }
                        
                            break
                    default:
                        print("SCORE ERROR")
                        var error: Error = ParseError()
                        if let scoreError = ScoreError(dictionary: dictionaryResult) {
                            error = scoreError
                            Log.print("Error On Score -\(dictionaryResult)-", type: LogType.Error)
                        }
                        else {
                            Log.print("Error On Parsing -\(dictionaryResult)-", type: LogType.Error)
                        }
                        completionHandler(Result.Failure(error))
                        break
                    }
                }
                break
            case Result.Failure(let error):
                completionHandler(Result.Failure(error))
                break
            }
        }
    }
}

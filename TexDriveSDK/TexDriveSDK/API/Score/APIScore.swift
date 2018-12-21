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
    init(apiSessionManager: APISessionManagerProtocol)
    func getScore(tripId: NSUUID, rxScore: PublishSubject<Score>)
    func getScore(tripId: NSUUID, completionHandler: @escaping (Result<Score>) -> ())
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
    func getScore(tripId: NSUUID, rxScore: PublishSubject<Score>) {
        let dictionary = ["trip_id":tripId.uuidString, "lang": Locale.current.identifier]
        
        self.sessionManager.get(parameters: dictionary) { (result) in
            switch result {
                case Result.Success(let dictionaryResult):
                    if let score = Score(dictionary: dictionaryResult) {
                        rxScore.onNext(score)
                    } else {
                        Log.print("Error On Parsing", type: LogType.Error)
                        rxScore.onError(ParsingError())
                    }
                break
            case Result.Failure(let error):
                rxScore.onError(error)
                break
            }
        }
    }
    
    func getScore(tripId: NSUUID, completionHandler: @escaping (Result<Score>) -> ()) {
        let dictionary = ["trip_id":tripId.uuidString, "lang": Locale.current.identifier]
        
        self.sessionManager.get(parameters: dictionary) { (result) in
            switch result {
            case Result.Success(let dictionaryResult):
                if let score = Score(dictionary: dictionaryResult) {
                    completionHandler(Result.Success(score))
                } else {
                    Log.print("Error On Parsing", type: LogType.Error)
                    completionHandler(Result.Failure(ParsingError()))
                }
                break
            case Result.Failure(let error):
                completionHandler(Result.Failure(error))
                break
            }
        }
    }
}

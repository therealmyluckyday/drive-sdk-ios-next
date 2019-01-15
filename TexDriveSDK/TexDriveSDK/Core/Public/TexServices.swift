//
//  Service.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift

public class TexServices {
    public let tripRecorder: TripRecorder // Add Lazy
    public let scoringClient: ScoringClientProtocol // Add Lazy
    public let tripIdFinished: PublishSubject<TripId>
    var configuration: ConfigurationProtocol {
        get {
            return _configuration
        }
    }
    
    private var _currentTripId : TripId?
    private let disposeBag = DisposeBag()
    
    @available(*, deprecated, message: "Please used triprecorder rxTripId property")
    public var currentTripId: TripId? {
        get {
            return _currentTripId
        }
    }
    
    private var _configuration: ConfigurationProtocol
    
    
    public init(configuration: ConfigurationProtocol) {
        _configuration = configuration
        let tripSessionManager = APITripSessionManager(configuration: configuration.tripInfos)
        tripIdFinished = tripSessionManager.tripIdFinished
        tripRecorder = TripRecorder(configuration: configuration, sessionManager: tripSessionManager)
        
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos)
        scoringClient = ScoringClient(sessionManager: scoreSessionManager, locale: configuration.locale)
        
        tripRecorder.rxTripId.asObservable().observeOn(MainScheduler.instance).subscribe {[weak self] (event) in
            if let tripId = event.element {
                self?._currentTripId = tripId
            }
        }.disposed(by: disposeBag)
    }
    
    class func service(withConfiguration configuration: ConfigurationProtocol) -> TexServices {
        return TexServices(configuration: configuration)
    }
    
    @available(*, deprecated, message: "Please used scoringClient property")
    func getScoringClient() -> (ScoringClientProtocol) {
        return scoringClient
    }
}

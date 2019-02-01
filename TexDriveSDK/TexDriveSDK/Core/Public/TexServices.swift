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
    // MARK: - Property
    // MARK: - Public
    public let tripIdFinished: PublishSubject<TripId>
    
    // MARK: - Private
    public let tripRecorder: TripRecorder
    public let scoreRetriever: ScoreRetrieverProtocol
    internal var configuration: ConfigurationProtocol
    private let disposeBag = DisposeBag()
    private var _currentTripId : TripId?
    
    @available(*, deprecated, message: "Please used triprecorder rxTripId property")
    internal var currentTripId: TripId? {
        get {
            return _currentTripId
        }
    }
    
    internal init(configuration: ConfigurationProtocol) {
        self.configuration = configuration
        let tripSessionManager = APITripSessionManager(configuration: configuration.tripInfos)
        tripIdFinished = tripSessionManager.tripIdFinished
        tripRecorder = TripRecorder(configuration: configuration, sessionManager: tripSessionManager)
        
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos)
        scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: configuration.locale)
        
        tripRecorder.rxTripId.asObservable().observeOn(MainScheduler.instance).subscribe {[weak self] (event) in
            if let tripId = event.element {
                self?._currentTripId = tripId
            }
        }.disposed(by: disposeBag)
    }
    
    
    public class func service(withConfiguration configuration: ConfigurationProtocol) -> TexServices {
        return TexServices(configuration: configuration)
    }
    
    @available(*, deprecated, message: "Please used scoreRetriever property")
    func getscoreRetriever() -> (ScoreRetrieverProtocol) {
        return scoreRetriever
    }
}

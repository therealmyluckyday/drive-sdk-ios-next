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
    public let logManager = LogManager()
    public var tripRecorder: TripRecorder? {
        get {
            return _tripRecorder
        }
    }
    public var scoreRetriever: ScoreRetrieverProtocol? {
        get {
            return _scoreRetriever
        }
    }
    
    public let rxScore = PublishSubject<Score>()
    
    // MARK: - Private
    private var disposeBag: DisposeBag?
    private var _tripRecorder: TripRecorder?
    private var _tripSessionManager: APITripSessionManager?
    private var _scoreRetriever: ScoreRetrieverProtocol?
    private static let sharedInstance = TexServices()
    
    // MARK: - Internal
    internal var configuration: ConfigurationProtocol?
    
    // MARK: - Internal Method
    internal func reconfigure(_ configuration: ConfigurationProtocol) {
        let rxDisposeBag = DisposeBag()
        disposeBag = rxDisposeBag
        self.configuration = configuration
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos)
        _scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: configuration.locale)
        let tripSessionManager = APITripSessionManager(configuration: configuration.tripInfos)
        _tripRecorder = TripRecorder(configuration: configuration, sessionManager: tripSessionManager)
        _tripRecorder?.tripIdFinished.asObserver().observeOn(configuration.rxScheduler).delay(RxTimeInterval(exactly: 10)!, scheduler: configuration.rxScheduler).subscribe { [weak self](event) in
            if let tripId = event.element, let rxScore = self?.rxScore {
                self?._scoreRetriever?.getScore(tripId: tripId, rxScore: rxScore)
            }
        }.disposed(by: rxDisposeBag)
    }
    
    // MARK: - Public Method
    public class func service(configuration: ConfigurationProtocol) -> TexServices {
        if let triprecorder = sharedInstance._tripRecorder {
            triprecorder.autoMode?.disable()
            triprecorder.stop()
        }
        sharedInstance.reconfigure(configuration)
        return sharedInstance
    }
}

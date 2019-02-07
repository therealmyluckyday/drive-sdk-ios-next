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
    public var tripRecorder: TripRecorder {
        get {
            return _tripRecorder!
        }
    }
    public var scoreRetriever: ScoreRetrieverProtocol {
        get {
            return _scoreRetriever!
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
    internal func reconfigure(_ configure: ConfigurationProtocol) {
        disposeBag = DisposeBag()
        self.configuration = configure
        let scoreSessionManager = APIScoreSessionManager(configuration: configure.tripInfos)
        _scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: configure.locale)
        let tripSessionManager = APITripSessionManager(configuration: configure.tripInfos)
        _tripRecorder = TripRecorder(configuration: configure, sessionManager: tripSessionManager)
        _tripRecorder?.tripIdFinished.asObserver().observeOn(configure.rxScheduler).delay(RxTimeInterval(exactly: 10)!, scheduler: configure.rxScheduler).subscribe { [weak self](event) in
            if let tripId = event.element, let rxScore = self?.rxScore {
                self?._scoreRetriever?.getScore(tripId: tripId, rxScore: rxScore)
            }
        }.disposed(by: disposeBag!)
    }
    
    // MARK: - Public Method
    public class func service(reconfigureWith configuration: ConfigurationProtocol) -> TexServices {
        if let triprecorder = sharedInstance._tripRecorder {
            triprecorder.stop()
        }
        sharedInstance.reconfigure(configuration)
        return sharedInstance
    }
}

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
    public var rxLog : PublishSubject<LogMessage> {
        get {
            return logManager.rxLog
        }
    }
    
    // MARK: - Private
    private let disposeBag = DisposeBag()
    private var _tripRecorder: TripRecorder?
    private var _tripSessionManager: APITripSessionManager?
    private var _scoreRetriever: ScoreRetrieverProtocol?
    private static let sharedInstance = TexServices()
    
    // MARK: - Internal
    internal var configuration: ConfigurationProtocol?
    
    // MARK: - Internal Method
    internal init() {
    }
    
    private func reconfigure(_ configure: ConfigurationProtocol) {
        self.configuration = configure
        let tripSessionManager = APITripSessionManager(configuration: configure.tripInfos)
        
        _tripRecorder = TripRecorder(configuration: configure, sessionManager: tripSessionManager)
        
        let scoreSessionManager = APIScoreSessionManager(configuration: configure.tripInfos)
        _scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: configure.locale)
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

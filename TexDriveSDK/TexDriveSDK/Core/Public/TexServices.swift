//
//  Service.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import RxSwift
import OSLog

extension OSLog {
    private static var texsubsystem = Bundle(for: TexServices.self)

    static let texDriveSDK = OSLog(subsystem: texsubsystem.bundleIdentifier!, category: "TexDriveSDK")
}

public class TexServices {
    // MARK: - Property
    // MARK: - Public
    public let logManager = LogManager()
    public var tripRecorder: TripRecorder? {
        get {
            return _tripRecorder
        }
    }
    public var scoringClient: ScoringClient? {
        get {
            return _scoreRetriever
        }
    }
    
    public let rxScore = PublishSubject<Score>()
    
    // MARK: - Private
    private var disposeBag: DisposeBag?
    private var _tripRecorder: TripRecorder?
    private var _tripSessionManager: APITripSessionManager?
    private var _scoreRetriever: ScoringClient?
    private static let sharedInstance = TexServices()
    
    // MARK: - Internal
    internal var configuration: ConfigurationProtocol?
    
    // MARK: - Internal Method
    internal func reconfigure(_ configuration: ConfigurationProtocol, isTesting: Bool) {
        let rxDisposeBag = DisposeBag()
        disposeBag = rxDisposeBag
        self.configuration = configuration
        // Configure API Score session
        let urlScoreSessionConfiguration = URLSessionConfiguration.default
        urlScoreSessionConfiguration.timeoutIntervalForResource = 15 * 60 * 60
        urlScoreSessionConfiguration.httpAdditionalHeaders = configuration.tripInfos.httpHeaders()
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos, urlSessionConfiguration: urlScoreSessionConfiguration)
        _scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: configuration.locale)
        // Configure API Trip session
        let urlTripSessionConfiguration = isTesting ? URLSessionConfiguration.default : URLSessionConfiguration.background(withIdentifier: "TexSession")
        urlTripSessionConfiguration.isDiscretionary = true
        urlTripSessionConfiguration.sessionSendsLaunchEvents = true
        urlTripSessionConfiguration.timeoutIntervalForResource = 15 * 60 * 60
        urlTripSessionConfiguration.httpAdditionalHeaders = configuration.tripInfos.httpHeaders()
        let tripSessionManager = APITripSessionManager(configuration: configuration.tripInfos, urlSessionConfiguration: urlTripSessionConfiguration)
        
        _tripRecorder = TripRecorder(configuration: configuration, sessionManager: tripSessionManager)
    }
    
    // MARK: - Public Method
    public class func service(configuration: ConfigurationProtocol, isTesting: Bool = false) -> TexServices {
        if let triprecorder = sharedInstance._tripRecorder {
            triprecorder.autoMode?.disable()
            triprecorder.stop()
        }
        sharedInstance.reconfigure(configuration, isTesting: isTesting)
        return sharedInstance
    }
}

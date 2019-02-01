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
    public let tripRecorder: TripRecorder
    public let scoreRetriever: ScoreRetrieverProtocol
    public var rxLog : PublishSubject<LogMessage> {
        get {
            return logManager.rxLog
        }
    }
    
    // MARK: - Private
    private let disposeBag = DisposeBag()
    
    // MARK: - Internal
    internal var configuration: ConfigurationProtocol
    
    // MARK: - Internal Method
    internal init(configuration: ConfigurationProtocol) {
        self.configuration = configuration
        let tripSessionManager = APITripSessionManager(configuration: configuration.tripInfos)
        
        tripRecorder = TripRecorder(configuration: configuration, sessionManager: tripSessionManager)
        
        let scoreSessionManager = APIScoreSessionManager(configuration: configuration.tripInfos)
        scoreRetriever = ScoreRetriever(sessionManager: scoreSessionManager, locale: configuration.locale)
        
            }
    
    // MARK: - Public Method
    public class func service(withConfiguration configuration: ConfigurationProtocol) -> TexServices {
        return TexServices(configuration: configuration)
    }
    
    @available(*, deprecated, message: "Please used scoreRetriever property")
    internal func getscoreRetriever() -> (ScoreRetrieverProtocol) {
        return scoreRetriever
    }
}

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
    var configuration: ConfigurationProtocol {
        get {
            return _configuration
        }
    }
    
    private var _currentTripId : NSUUID?
    private let disposeBag = DisposeBag()
    
    @available(*, deprecated, message: "Please used triprecorder rxTripId property")
    public var currentTripId: NSUUID? {
        get {
            return _currentTripId
        }
    }
    
    private var _configuration: ConfigurationProtocol
    
    public init(configuration: ConfigurationProtocol) {
        _configuration = configuration
        let sessionManager = APISessionManager(configuration: configuration.tripInfos)
        tripRecorder = TripRecorder(configuration: configuration, sessionManager: sessionManager)
        scoringClient = ScoringClient(sessionManager: sessionManager, locale: configuration.locale)
        
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

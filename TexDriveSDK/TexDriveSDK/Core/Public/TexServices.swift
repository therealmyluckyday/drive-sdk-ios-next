//
//  Service.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

public class TexServices {
    public let tripRecorder: TripRecorder
    public let scoringClient: ScoringClientProtocol
    var config: ConfigurationProtocol {
        get {
            return _config
        }
    }
    
    private var _config: ConfigurationProtocol
    
    public init(configuration: ConfigurationProtocol) {
        _config = configuration
        let sessionManager = configuration.generateAPISessionManager()
        tripRecorder = TripRecorder(config: configuration, sessionManager: sessionManager)
        scoringClient = ScoringClient(sessionManager: sessionManager)
    }
    
    class func service(withConfiguration configuration: ConfigurationProtocol) -> TexServices {
        return TexServices(configuration: configuration)
    }
    
    @available(*, deprecated, message: "Please used scoringClient property")
    func getScoringClient() -> (ScoringClientProtocol) {
        return scoringClient
    }
}

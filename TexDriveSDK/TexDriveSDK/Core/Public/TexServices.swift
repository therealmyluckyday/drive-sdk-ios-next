//
//  Service.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

public class TexServices {
    let tripRecorder: TripRecorder
    var config: ConfigurationProtocol {
        get {
            return _config
        }
    }
    
    private var _config: ConfigurationProtocol
    
    init(configuration: ConfigurationProtocol) {
        _config = configuration
        tripRecorder = TripRecorder(config: configuration)
    }
    
    class func service(withConfiguration configuration: ConfigurationProtocol) -> TexServices {
        return TexServices(configuration: configuration)
    }
    
    func getScoringClient() -> (ScoringClientProtocol) {
        let scoringClient = ScoringClient()
        return scoringClient
    }
}

//
//  Service.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

public class Service {
    let tripRecorder: TripRecorder
    var config: Config {
        get {
            return _config
        }
    }
    
    private var _config: Config
    
    init(configuration: Config) {
        _config = configuration
        tripRecorder = TripRecorder(configuration: configuration)
    }
    
    class func service(withConfiguration configuration: Config) -> Service{
        return Service(configuration: configuration)
    }
}

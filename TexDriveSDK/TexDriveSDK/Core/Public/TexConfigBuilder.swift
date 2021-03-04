//
//  TexConfigBuilder.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 12/04/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import Foundation
import CoreLocation

public class TexConfigBuilder {
    var appId: String {
        get {
            return _config.tripInfos.appId
        }
    }
    var texUser: TexUser {
        get {
            return _config.tripInfos.user
        }
    }
    var config: TexConfig {
        get {
            return _config
        }
    }
    
    var _config: TexConfig

    public init(appId: String, texUser: TexUser, isAPIV2: Bool) {
        _config = TexConfig(applicationId: appId, currentUser: texUser, isAPIV2: isAPIV2)
    }
    
    public func enableTripRecorder(locationManager: LocationManager = LocationManager()) throws {
        let locationfeature : TripRecorderFeature = TripRecorderFeature.Location(locationManager)
    
        for feature in _config.tripRecorderFeatures {
            switch feature {
            case .Location(_):
                return
            case .Battery(_):
                break
            case .PhoneCall(_):
                break
            case .Motion(_):
                break
            }
        }
        _config.tripRecorderFeatures.append(locationfeature)
    }
    
    public func select(platform: Platform, isAPIV2: Bool) {
        _config.select(domain: platform, isAPIV2: isAPIV2)
    }
    
    public func build() -> TexConfig {
        return config.copy()
    }
}





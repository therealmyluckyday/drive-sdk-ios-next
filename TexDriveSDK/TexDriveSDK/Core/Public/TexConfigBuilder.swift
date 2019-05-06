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

    public init(appId: String, texUser: TexUser) {
        _config = TexConfig(applicationId: appId, currentUser: texUser)
    }
    
    public func enableTripRecorder(locationManager: CLLocationManager = CLLocationManager()) throws {
        let autoModeLocationSensor = AutoModeLocationSensor(locationManager)
        let locationSensor: LocationSensor = LocationSensor(locationManager)
        let mainLocationManager = LocationManager(autoModeLocationSensor, trackerLocationSensor: locationSensor)
        let locationfeature : TripRecorderFeature = TripRecorderFeature.Location(mainLocationManager)
        try TexConfig.activable(features: [locationfeature])
    
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
    
    public func select(platform: Platform) {
        _config.select(domain: platform)
    }
    
    public func build() -> TexConfig {
        return config.copy()
    }
}





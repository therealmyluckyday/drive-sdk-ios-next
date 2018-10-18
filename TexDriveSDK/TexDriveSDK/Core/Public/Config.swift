//
//  Config.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreLocation

public enum ConfigurationError: Error {
    case LocationNotDetermined(String)
    case MotionNotAvailable(String)
}

public enum Mode {
    case auto
    case autoBlueTooth
    case manual
}

public class Config {
    let appId: String
    let locale: Locale
    let user: User
    let mode: Mode
    let tripRecorderFeatures: [TripRecorderFeature]
    
    public init?(applicationId: String, applicationLocale: Locale, currentUser: User, currentMode: Mode, currentTripRecorderFeatures: [TripRecorderFeature]) throws {
        try currentTripRecorderFeatures.forEach { (feature) in
            switch (feature, feature.canActivate()) {
            case (TripRecorderFeature.Location, false):
                throw ConfigurationError.LocationNotDetermined("Need to ask user permission: requestAlwaysAuthorization() on a CLLocationManager")
            case (TripRecorderFeature.Motion, false):
                throw ConfigurationError.MotionNotAvailable("Need to configure the UIRequiredDeviceCapabilities key of its Info.plist file with the accelerometer and gyroscope values")
                case (_, false):
                    print("ERROR : \(feature) Can not activate")
            default:
                print("\(feature) \(feature.canActivate())")
                break
            }
        }
        
        appId = applicationId
        locale = applicationLocale
        user = currentUser
        mode = currentMode
        tripRecorderFeatures = currentTripRecorderFeatures
    }
}

// TODO
//@property(readonly) AXAPlatform platform;
//@property(readonly) BOOL isObdManagerEnabled;
//@property(readonly) BOOL isScoreDatabaseEnabled;
//@property(readonly) BOOL isPredictionServiceEnabled;
//@property(readonly) BOOL isScoringServiceEnabled;

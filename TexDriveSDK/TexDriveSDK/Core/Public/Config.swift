//
//  Config.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreLocation
import CallKit
import CoreMotion
import os

public protocol AppDelegateText: UIApplicationDelegate {
    var backgroundCompletionHandler: (() -> ())? { get set }
}

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
    
    
    public convenience init?(applicationId: String, applicationLocale: Locale, currentUser: User, currentMode: Mode) throws {
        let locationfeature : TripRecorderFeature = TripRecorderFeature.Location(CLLocationManager())
        let batteryfeature : TripRecorderFeature = TripRecorderFeature.Battery(UIDevice.current)
        let phoneCallFeature : TripRecorderFeature = TripRecorderFeature.PhoneCall(CXCallObserver())
        let sensor = CMMotionManager()
        let motionFeature = TripRecorderFeature.Motion(sensor)
        
        let tripRecorderFeatures = [locationfeature, batteryfeature, phoneCallFeature, motionFeature]
        try self.init(applicationId: applicationId, applicationLocale: applicationLocale, currentUser: currentUser, currentMode: currentMode, currentTripRecorderFeatures: tripRecorderFeatures)
    }
    
    init?(applicationId: String, applicationLocale: Locale, currentUser: User, currentMode: Mode, currentTripRecorderFeatures: [TripRecorderFeature]) throws {
        try currentTripRecorderFeatures.forEach { (feature) in
            switch (feature, feature.canActivate()) {
            case (TripRecorderFeature.Location, false):
                Log.print("FEATURE \(feature) Can not activate", type: .Error)
                throw ConfigurationError.LocationNotDetermined("Need to ask user permission: requestAlwaysAuthorization() on a CLLocationManager")
            case (TripRecorderFeature.Motion, false):
                Log.print("FEATURE \(feature) Can not activate", type: .Error)
                throw ConfigurationError.MotionNotAvailable("Need to configure the UIRequiredDeviceCapabilities key of its Info.plist file with the accelerometer and gyroscope values. And add NSMotionUsageDescription in Info.plist. This feature is not availaible on simulator")
            case (_, false):
                Log.print("FEATURE \(feature) Can not activate", type: .Error)
            default:
                Log.print("Feature can activate")
                break
            }
        }
        appId = applicationId
        locale = applicationLocale
        user = currentUser
        mode = currentMode
        tripRecorderFeatures = currentTripRecorderFeatures
        
        do {
            let regex = try NSRegularExpression(pattern: ".*.*", options: NSRegularExpression.Options.caseInsensitive)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
            os_log("-------------REGEX ERROR--------------- %@", log: customLog, type: .error, error.localizedDescription)
        }
    }
}

// TODO
//@property(readonly) AXAPlatform platform;
//@property(readonly) BOOL isObdManagerEnabled;
//@property(readonly) BOOL isScoreDatabaseEnabled;
//@property(readonly) BOOL isPredictionServiceEnabled;
//@property(readonly) BOOL isScoringServiceEnabled;

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
import RxSwift

public protocol AppDelegateText: UIApplicationDelegate {
    var backgroundCompletionHandler: (() -> ())? { get set }
}

public enum ConfigurationError: Error {
    case LocationNotDetermined(String)
    case MotionNotAvailable(String)
}

public protocol ConfigurationProtocol {
    var tripRecorderFeatures: [TripRecorderFeature] { get }
    var rx_log: PublishSubject<LogDetail> { get }
    func generateAPISessionManager() -> APISessionManagerProtocol
}

public enum Mode {
    case auto
    case autoBlueTooth
    case manual
}

public class Config: ConfigurationProtocol {
    public var rx_log: PublishSubject<LogDetail> {
        get {
            return logFactory.rx_logOutput
        }
    }
    public let tripRecorderFeatures: [TripRecorderFeature]
    
    let appId: String
    let locale: Locale
    let user: User
    let mode: Mode
    let logFactory = LogRxFactory()
    
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
            let regex = try NSRegularExpression(pattern: ".*SecTrustExtension.swift.*", options: NSRegularExpression.Options.caseInsensitive)
            
            Log.configure(loggerFactory: logFactory)
            Log.configure(regex: regex, logType: LogType.Info)
        } catch {
            let customLog = OSLog(subsystem: "fr.axa.tex", category: #file)
            os_log("-------------REGEX ERROR--------------- %@", log: customLog, type: .error, error.localizedDescription)
        }
    }
    
    public func generateAPISessionManager() -> APISessionManagerProtocol {
        return APISessionManager(configuration: APIConfiguration(appId: appId, domain: Domain.Preproduction, user: user))
    }
}

// TODO
//@property(readonly) AXAPlatform platform;
//@property(readonly) BOOL isObdManagerEnabled;
//@property(readonly) BOOL isScoreDatabaseEnabled;
//@property(readonly) BOOL isPredictionServiceEnabled;
//@property(readonly) BOOL isScoringServiceEnabled;

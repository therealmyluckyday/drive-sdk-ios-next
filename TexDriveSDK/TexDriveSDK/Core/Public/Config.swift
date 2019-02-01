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

// This protocol is used on APISessionManager in backgroundmode
public protocol AppDelegateTex: UIApplicationDelegate {
    var backgroundCompletionHandler: (() -> ())? { get set }
}

public enum ConfigurationError: Error {
    case LocationNotDetermined(String)
    case MotionNotAvailable(String)
}

public protocol ConfigurationProtocol: LogConfiguration, TripRecorderConfiguration , ScoringClientConfiguration {
}

public protocol TripRecorderConfiguration: APISessionManagerConfiguration {
    var tripRecorderFeatures: [TripRecorderFeature] { get }
    var rxScheduler: SerialDispatchQueueScheduler { get }
}

public protocol LogConfiguration {
    var rxLog: PublishSubject<LogMessage> { get }
    func log(regex: NSRegularExpression, logType: LogType)
}

public protocol APISessionManagerConfiguration {
    var tripInfos: TripInfos { get }
}

public protocol ScoringClientConfiguration {
    var locale: Locale { get }
}

public class Config: ConfigurationProtocol, ScoringClientConfiguration, APISessionManagerConfiguration {
    // LogConfiguration
    public var rxLog: PublishSubject<LogMessage> {
        get {
            return logFactory.rxLogOutput
        }
    }
    let logFactory = LogRx()
    
    public let tripRecorderFeatures: [TripRecorderFeature]
    public let rxScheduler = MainScheduler.asyncInstance
    
    // ScoringClientConfiguration
    public let locale: Locale

    // APISessionManagerConfiguration
    public let tripInfos: TripInfos
    
    public convenience init?(applicationId: String, applicationLocale: Locale = Locale.current, currentUser: User = User.Anonymous) throws {
        let locationfeature : TripRecorderFeature = TripRecorderFeature.Location(CLLocationManager())

        #if targetEnvironment(simulator)
        let batteryfeature : TripRecorderFeature = TripRecorderFeature.Battery(UIDevice.current)
        let phoneCallFeature : TripRecorderFeature = TripRecorderFeature.PhoneCall(CXCallObserver())
        let tripRecorderFeatures = [locationfeature, batteryfeature, phoneCallFeature]
        #else
//        let motionFeature = TripRecorderFeature.Motion(CMMotionManager())
//        let tripRecorderFeatures = [locationfeature, batteryfeature, phoneCallFeature, motionFeature]
        let tripRecorderFeatures = [locationfeature]
        #endif
        try self.init(applicationId: applicationId, applicationLocale: applicationLocale, currentUser: currentUser, currentTripRecorderFeatures: tripRecorderFeatures)
    }
    
    init?(applicationId: String, applicationLocale: Locale, currentUser: User, currentTripRecorderFeatures: [TripRecorderFeature]) throws {
        try Config.activable(features: currentTripRecorderFeatures)
        tripInfos = TripInfos(appId: applicationId, user: currentUser, domain: Domain.Preproduction)
        locale = applicationLocale
        tripRecorderFeatures = currentTripRecorderFeatures
        Log.configure(logger: logFactory)
    }
    
    static func activable(features: [TripRecorderFeature]) throws {
        try features.forEach { (feature) in
            switch (feature, feature.canActivate()) {
            case (TripRecorderFeature.Location, false):
                Log.print("Feature \(feature) Can not activate", type: .Error)
                throw ConfigurationError.LocationNotDetermined("Need to ask user permission: requestAlwaysAuthorization() on a CLLocationManager")
            case (TripRecorderFeature.Motion, false):
                Log.print("Feature \(feature) Can not activate", type: .Error)
                throw ConfigurationError.MotionNotAvailable("Need to configure the UIRequiredDeviceCapabilities key of its Info.plist file with the accelerometer and gyroscope values. And add NSMotionUsageDescription in Info.plist. This feature is not availaible on simulator")
            case (_, false):
                Log.print("Feature \(feature) Can not activate", type: .Error)
            default:
                Log.print("Feature can activate")
                break
            }
        }
    }
    
    // LogConfiguration
    public func log(regex: NSRegularExpression, logType: LogType) {
        Log.configure(regex: regex, logType: logType)
    }
}


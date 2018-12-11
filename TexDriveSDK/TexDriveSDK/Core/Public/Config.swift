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

public protocol ConfigurationProtocol {
    var tripRecorderFeatures: [TripRecorderFeature] { get }
    var rx_scheduler: SerialDispatchQueueScheduler { get }
    var rx_log: PublishSubject<LogMessage> { get }
    func log(regex: NSRegularExpression, logType: LogType)
    func generateAPISessionManager() -> APISessionManagerProtocol
}

public class Config: ConfigurationProtocol {
    public var rx_log: PublishSubject<LogMessage> {
        get {
            return logFactory.rx_logOutput
        }
    }
    public let tripRecorderFeatures: [TripRecorderFeature]
    public let rx_scheduler = MainScheduler.asyncInstance
    let appId: String
    let locale: Locale
    let user: User
    let logFactory = LogRxFactory()
    
    public convenience init?(applicationId: String, applicationLocale: Locale, currentUser: User) throws {
        let locationfeature : TripRecorderFeature = TripRecorderFeature.Location(CLLocationManager())
        let batteryfeature : TripRecorderFeature = TripRecorderFeature.Battery(UIDevice.current)
        let phoneCallFeature : TripRecorderFeature = TripRecorderFeature.PhoneCall(CXCallObserver())
        let sensor = CMMotionManager()
        let motionFeature = TripRecorderFeature.Motion(sensor)
        
        let tripRecorderFeatures = [locationfeature, batteryfeature, phoneCallFeature]
        try self.init(applicationId: applicationId, applicationLocale: applicationLocale, currentUser: currentUser, currentTripRecorderFeatures: tripRecorderFeatures)
    }
    
    init?(applicationId: String, applicationLocale: Locale, currentUser: User, currentTripRecorderFeatures: [TripRecorderFeature]) throws {
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
        tripRecorderFeatures = currentTripRecorderFeatures
        Log.configure(loggerFactory: logFactory)
        
    }
    
    public func log(regex: NSRegularExpression, logType: LogType) {
        Log.configure(regex: regex, logType: logType)
    }
    
    public func generateAPISessionManager() -> APISessionManagerProtocol {
        return APISessionManager(configuration: APIConfiguration(appId: appId, domain: Domain.Preproduction, user: user))
    }
}

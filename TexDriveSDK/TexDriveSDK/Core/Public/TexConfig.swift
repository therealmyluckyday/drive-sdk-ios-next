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

public protocol Copyable {
    associatedtype ObjectType = Self
    func Copy() -> ObjectType
}

// This protocol is used on APISessionManager in backgroundmode
public protocol AppDelegateTex: UIApplicationDelegate {
    var backgroundCompletionHandler: (() -> ())? { get set }
}

public enum ConfigurationError: Error {
    case LocationNotDetermined(String)
    case MotionNotAvailable(String)
}

public protocol ConfigurationProtocol: TripRecorderConfiguration , ScoringClientConfiguration {
}

public protocol TripRecorderConfiguration: APISessionManagerConfiguration {
    var tripRecorderFeatures: [TripRecorderFeature] { get }
    var rxScheduler: SerialDispatchQueueScheduler { get }
}


public protocol APISessionManagerConfiguration {
    var tripInfos: TripInfos { get }
}

public protocol ScoringClientConfiguration {
    var locale: Locale { get }
}

public class TexConfig: ConfigurationProtocol, ScoringClientConfiguration, APISessionManagerConfiguration {
    // MARK: - Property
    public var tripRecorderFeatures = [TripRecorderFeature]()
    public let rxScheduler = MainScheduler.asyncInstance
    
    // MARK: - ScoringClientConfiguration
    public var locale = Locale.current

    // MARK: - APISessionManagerConfiguration
    public var tripInfos: TripInfos
    public var domain = Platform.Production
    
    // MARK: - Lifecycle
    internal init(applicationId: String, currentUser: TexUser) {
        tripInfos = TripInfos(appId: applicationId, user: currentUser, domain: domain)
    }
    
    // MARK: - Public method
    func select(domain: Platform) {
        self.domain = domain
        tripInfos = TripInfos(appId: self.tripInfos.appId, user: self.tripInfos.user, domain: domain)
    }
    
    static func activable(features: [TripRecorderFeature]) throws {
        try features.forEach { (feature) in
            switch (feature, feature.canActivate()) {
            case (TripRecorderFeature.Location, false):
                Log.print("Feature \(feature) Can not activate", type: .Error)
                throw ConfigurationError.LocationNotDetermined("[TexDriveSDK] Need to ask user permission: requestAlwaysAuthorization() on a CLLocationManager")
            case (TripRecorderFeature.Motion, false):
                Log.print("Feature \(feature) Can not activate", type: .Error)
                throw ConfigurationError.MotionNotAvailable("[TexDriveSDK] Need to configure the UIRequiredDeviceCapabilities key of its Info.plist file with the accelerometer and gyroscope values. And add NSMotionUsageDescription in Info.plist. This feature is not availaible on simulator")
            case (_, false):
                Log.print("[TexDriveSDK] Feature \(feature) Can not activate", type: .Error)
            default:
                Log.print("Feature can activate")
                break
            }
        }
    }
    
    // MARK: - Copyable Protocol
    func copy() -> TexConfig {
        let copy = TexConfig(applicationId: tripInfos.appId, currentUser: tripInfos.user)
        copy.select(domain: domain)
        copy.locale = locale
        copy.tripRecorderFeatures = tripRecorderFeatures.map({ (feature) -> TripRecorderFeature in
            return feature
        })
        return copy
    }
}


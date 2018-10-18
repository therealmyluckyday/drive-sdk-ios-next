//
//  TripRecorderFeature.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 11/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation
import CoreLocation
import CallKit
import CoreMotion

public enum TripRecorderFeature {
    case Location(CLLocationManager) // CLLocationManager is the location sensor
    case Battery(UIDevice) // UIDevice is the battery sensor
    case PhoneCall(CXCallObserver) // CXCallObserver is the Call Sensor
    case Motion(CMMotionManager) // CMMotionManager is the Motion Sensor
    
    func canActivate() -> Bool {
        switch self {
        case .Location(let locationManager):
            return type(of: locationManager).authorizationStatus() != .notDetermined
        case .Motion(let motionManager):
            return motionManager.isDeviceMotionAvailable
        default:
            return true
        }
    }
}

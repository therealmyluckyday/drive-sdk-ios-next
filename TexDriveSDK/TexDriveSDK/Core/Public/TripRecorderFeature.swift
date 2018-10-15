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

public enum TripRecorderFeature {
    case Location(CLLocationManager)
    case Battery(UIDevice)
    case PhoneCall(CXCallObserver)
    
    func canActivate() -> Bool {
        switch self {
        case .Location(let locationManager):
            return type(of: locationManager).authorizationStatus() != .notDetermined
        default:
            return true
        }
    }
}

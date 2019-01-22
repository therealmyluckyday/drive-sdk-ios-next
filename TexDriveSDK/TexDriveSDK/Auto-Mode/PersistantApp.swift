//
//  PersistantApp.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 21/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import Foundation
import CoreLocation

class PersistantApp: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.requestAlwaysAuthorization()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    // MARK : CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.print("didUpdateLocations")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.print("didFailWithError")
    }
}

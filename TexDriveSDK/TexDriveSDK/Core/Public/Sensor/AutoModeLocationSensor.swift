//
//  AutoModeLocationSensor.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/04/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import CoreLocation
import OSLog

public class AutoModeLocationSensor: LocationSensor {
    var slcLocationManager = CLLocationManager()
    var state = LocationManagerState.disabled
    
    // MARK: - Public Method
    
    func configure(_ locationManager: CLLocationManager) {
        #if targetEnvironment(simulator)
        #else
        locationManager.requestAlwaysAuthorization()
        #endif
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        
        #if targetEnvironment(simulator)
        #else
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        #endif
    }
    
    func change(state: LocationManagerState) {
        DispatchQueue.main.async() {
            //Log.print("[AutomodeLocationSensor] isSameState %@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(state==self.state)" )
            if state != self.state {
                switch state {
                case .disabled:
                    Log.print("State \(state)")
                    self.stopUpdatingLocation()
                    self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.state = .disabled
                case .significantLocationChanges:
                    Log.print("State \(state)")
                    self.state = .significantLocationChanges
                    self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.stopUpdatingLocation()
                    self.configure(self.slcLocationManager)
                    self.slcLocationManager.startMonitoringSignificantLocationChanges()
                case .locationChanges:
                    if (self.state == .disabled || self.state == .significantLocationChanges) {
                        Log.print("State \(state)")
                        self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                        self.stopUpdatingLocation()
                        self.configure(self.clLocationManager)
                        self.startUpdatingLocation()
                    }
                    self.state = .locationChanges
                }
            }
        }
    }
}

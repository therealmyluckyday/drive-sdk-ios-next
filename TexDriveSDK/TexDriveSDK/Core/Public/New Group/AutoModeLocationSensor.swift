//
//  AutoModeLocationSensor.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/04/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import CoreLocation

public class AutoModeLocationSensor: LocationSensor {
    var slcLocationManager = CLLocationManager()
    var state = LocationManagerState.disabled
    
    // MARK: - Public Method
    
    func configure(_ locationManager: CLLocationManager) {
        
        #if targetEnvironment(simulator)
        #else
        locationManager.requestAlwaysAuthorization()
        #endif
        locationManager.delegate = self
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
            if state != self.state {
                switch state {
                case .disabled:
                    Log.print("State \(state)")
                    self.clLocationManager.stopUpdatingLocation()
                    self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.state = .disabled
                case .significantLocationChanges:
                    Log.print("State \(state)")
                    self.state = .significantLocationChanges
                    self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.clLocationManager.stopUpdatingLocation()
                    self.configure(self.slcLocationManager)
                    self.slcLocationManager.startMonitoringSignificantLocationChanges()
                case .locationChanges:
                    if (self.state == .disabled || self.state == .significantLocationChanges) {
                        Log.print("State \(state)")
                        self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                        self.clLocationManager.stopUpdatingLocation()
                        self.configure(self.clLocationManager)
                        self.clLocationManager.startUpdatingLocation()
                    }
                    self.state = .locationChanges
                }
            }
        }
    }
}

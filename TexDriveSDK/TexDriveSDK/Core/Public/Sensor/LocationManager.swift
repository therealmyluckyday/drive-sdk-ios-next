//
//  LocationManager.swift
//  TexDriveSDK
//  Aka One LocationManager to rule them all
//  Created by Erwan Masson on 28/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//
import CoreLocation

public class LocationManager: NSObject {
    let autoModeLocationSensor: AutoModeLocationSensor
    let trackerLocationSensor: LocationSensor
    
    init(autoModeLocationSensor: AutoModeLocationSensor, locationSensor: LocationSensor) {
        self.autoModeLocationSensor = autoModeLocationSensor
        self.trackerLocationSensor = locationSensor
    }
    
    public convenience init(locationManager: CLLocationManager = CLLocationManager()) {
        self.init(autoModeLocationSensor: AutoModeLocationSensor(locationManager), locationSensor: LocationSensor(locationManager))
        #if targetEnvironment(simulator)
        #else
        self.trackerLocationSensor.clLocationManager.requestAlwaysAuthorization()
        #endif
    }
    // MARK: - Public Method
    func configure(_ locationManager: CLLocationManager) {
        #if targetEnvironment(simulator)
        #else
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        #endif
        
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
    }
    
    func change(state: LocationManagerState) {
        //Log.print("[AutomodeLocationSensor] isSameState %@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(state==self.state)" )
        if state != self.autoModeLocationSensor.state {
            switch state {
            case .disabled:
                Log.print("State \(state)")
                self.autoModeLocationSensor.clLocationManager.stopUpdatingLocation()
                self.autoModeLocationSensor.slcLocationManager.stopMonitoringSignificantLocationChanges()
                self.autoModeLocationSensor.state = .disabled
            case .significantLocationChanges:
                Log.print("State \(state)")
                self.autoModeLocationSensor.state = .significantLocationChanges
                self.trackerLocationSensor.stopUpdatingLocation()
                self.autoModeLocationSensor.slcLocationManager.stopMonitoringSignificantLocationChanges()
                self.autoModeLocationSensor.clLocationManager.stopUpdatingLocation()
                self.configure(self.autoModeLocationSensor.slcLocationManager)
                self.autoModeLocationSensor.slcLocationManager.startMonitoringSignificantLocationChanges()
            case .locationChanges:
                if (self.autoModeLocationSensor.state == .disabled || self.autoModeLocationSensor.state == .significantLocationChanges) {
                    Log.print("State \(state)")
                    self.autoModeLocationSensor.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.autoModeLocationSensor.clLocationManager.stopUpdatingLocation()
                    self.configure(self.autoModeLocationSensor.clLocationManager)
                    self.autoModeLocationSensor.clLocationManager.startUpdatingLocation()
                    self.trackerLocationSensor.state = .locationChanges
                }
                self.autoModeLocationSensor.state = .locationChanges
            }
        }
    }
}


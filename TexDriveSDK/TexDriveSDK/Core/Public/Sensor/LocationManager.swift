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
    }
    
    // MARK: - Public Method
    func configure(_ locationManager: CLLocationManager) {
        #if targetEnvironment(simulator)
        #else
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        #endif
        
        locationManager.distanceFilter = 100
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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
                self.autoModeLocationSensor.slcLocationManager.stopMonitoringSignificantLocationChanges()
                self.autoModeLocationSensor.clLocationManager.stopUpdatingLocation()
                self.trackerLocationSensor.clLocationManager.stopUpdatingLocation()
                if self.autoModeLocationSensor.needToRefreshLocationManager {
                    self.autoModeLocationSensor.slcLocationManager = CLLocationManager()
                }
                self.autoModeLocationSensor.configureWithRXCoreLocation()
                self.configure(self.autoModeLocationSensor.slcLocationManager)
                self.autoModeLocationSensor.slcLocationManager.startMonitoringSignificantLocationChanges()
            case .locationChanges:
                if (self.autoModeLocationSensor.state == .disabled || self.autoModeLocationSensor.state == .significantLocationChanges) {
                    Log.print("State \(state)")
                    // self.autoModeLocationSensor.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.autoModeLocationSensor.clLocationManager.stopUpdatingLocation()
                    self.autoModeLocationSensor.clLocationManager = CLLocationManager()
                    self.configure(self.autoModeLocationSensor.clLocationManager)
                    self.autoModeLocationSensor.configureWithRXCoreLocation()
                    self.autoModeLocationSensor.clLocationManager.startUpdatingLocation()
                    self.trackerLocationSensor.clLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                    self.trackerLocationSensor.clLocationManager.startUpdatingLocation()
                    self.trackerLocationSensor.state = .locationChanges
                }
                self.autoModeLocationSensor.state = .locationChanges
            }
        }
    }
}


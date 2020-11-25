//
//  LocationManager.swift
//  TexDriveSDK
//
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
    
}


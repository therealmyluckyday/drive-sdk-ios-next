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
    
    init(_ automodeLocationSensor: AutoModeLocationSensor = AutoModeLocationSensor(CLLocationManager()), trackerLocationSensor locationSensor: LocationSensor = LocationSensor(CLLocationManager())) {
        autoModeLocationSensor = automodeLocationSensor
        self.trackerLocationSensor = locationSensor
        #if targetEnvironment(simulator)
        #else
        self.trackerLocationSensor.clLocationManager.requestAlwaysAuthorization()
        #endif
    }
    
}


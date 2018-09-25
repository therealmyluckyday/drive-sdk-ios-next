//
//  LocationTracker.swift
//  TexDriveSDK
//
//  Created by Axa on 24/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class LocationTracker: NSObject, Tracker, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    var locationFix: Variable<LocationFix> = Variable(LocationFix(fixId: "0", timestamp: Date()))
    
    override init() {
        super.init()
    }
    
    func enableTracking() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    func disableTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func provideFix() {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let locationFix = LocationFix(fixId: "0", timestamp: Date(), latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: location.horizontalAccuracy, speed: location.speed, bearing: location.course, altitude: location.altitude)
        self.locationFix.value = locationFix
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error : \(error)")
    }
    
    deinit {
        print("location tracker disposed")
        disableTracking()
    }
}

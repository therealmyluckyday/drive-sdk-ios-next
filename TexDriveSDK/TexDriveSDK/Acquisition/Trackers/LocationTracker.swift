//
//  LocationTracker.swift
//  TexDriveSDK
//
//  Created by Axa on 24/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import CoreLocation
import RxSwift

class LocationTracker: NSObject, Tracker, CLLocationManagerDelegate {
    // MARK: Property
    typealias T = LocationFix
    private let locationManager: CLLocationManager
    private var rxLocationFix = PublishSubject<Result<LocationFix>>()
    
    // MARK: Lifecycle method
    init(sensor: CLLocationManager) {
        locationManager = sensor
    }
    
    deinit {
        disableTracking()
    }
    
    // MARK: Tracker Protocol
    func enableTracking() {
        guard type(of: locationManager).authorizationStatus() != .notDetermined else {
            let error = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined requestAlwaysAuthorization()", code: CLError.denied.rawValue, userInfo: nil))
            rxLocationFix.onNext(Result.Failure(error))
            return
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        

        locationManager.startUpdatingLocation()
    }
    
    func disableTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func provideFix() -> PublishSubject<Result<LocationFix>> {
        return rxLocationFix
    }
    
    // MARK: Tracker method for Location Fix
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let locationFix = LocationFix(timestamp: location.timestamp.timeIntervalSince1970, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: location.horizontalAccuracy, speed: location.speed, bearing: location.course, altitude: location.altitude)
        rxLocationFix.onNext(Result.Success(locationFix))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        rxLocationFix.onNext(Result.Failure(error))
    }
}

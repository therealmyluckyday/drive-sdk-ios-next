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
    // MARK: Property
    typealias T = LocationFix
    private let locationManager: CLLocationManager
    private var rx_locationFix = PublishSubject<Result<LocationFix>>()
    
    // MARK: Lifecycle method
    init(locationSensor: CLLocationManager) {
        locationManager = locationSensor
    }
    
    deinit {
        disableTracking()
    }
    
    // MARK: Tracker Protocol
    func enableTracking() {
        guard CLLocationManager.authorizationStatus() != .notDetermined else {
            let error = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined", code: CLError.denied.rawValue, userInfo: nil))
            rx_locationFix.onNext(Result.Failure(error))
//            locationManager.requestAlwaysAuthorization() -> REsponsability to user
            return
        }
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }

        locationManager.startUpdatingLocation()
    }
    
    func disableTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func provideFix() -> PublishSubject<Result<LocationFix>> {
        return rx_locationFix
    }
    
    // MARK: Tracker method for Location Fix
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let locationFix = LocationFix(timestamp: location.timestamp, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: location.horizontalAccuracy, speed: location.speed, bearing: location.course, altitude: location.altitude)
        rx_locationFix.onNext(Result.Success(locationFix))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        rx_locationFix.onNext(Result.Failure(error))
    }
}

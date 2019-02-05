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
    
    // MARK: - Tracker Protocol
    func enableTracking() {
        guard type(of: locationManager).authorizationStatus() != .notDetermined else {
            let error = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined requestAlwaysAuthorization()", code: CLError.denied.rawValue, userInfo: nil))
            rxLocationFix.onNext(Result.Failure(error))
            return
        }
        
        locationManager.delegate = self
        locationManager.disallowDeferredLocationUpdates()
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.deferredLocationUpdatesAvailable() {
            let distance: CLLocationDistance = 4000
            let time: TimeInterval = 100
            self.locationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: time)
        }

        locationManager.startUpdatingLocation()
    }
    
    func disableTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func provideFix() -> PublishSubject<Result<LocationFix>> {
        return rxLocationFix
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.print("didUpdateLocations")
        guard let _ = locations.last else {
            return
        }
        let fixes = locations.map { (location) -> Result<LocationFix> in
            return Result.Success(LocationFix(timestamp: location.timestamp.timeIntervalSince1970, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: location.horizontalAccuracy, speed: location.speed, bearing: location.course, altitude: location.altitude))
        }
        fixes.forEach { (result) in
             rxLocationFix.onNext(result)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        rxLocationFix.onNext(Result.Failure(error))
    }
}

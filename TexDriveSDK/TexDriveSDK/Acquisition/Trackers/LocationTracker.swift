//
//  LocationTracker.swift
//  TexDriveSDK
//
//  Created by Axa on 24/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import UIKit
import CoreLocation
import RxCoreLocation
import RxSwift
import RxCocoa
import OSLog

class LocationTracker: NSObject, Tracker {
    // MARK: Property
    let maxDistanceAccuracy: CLLocationAccuracy = 100
    typealias T = LocationFix
    private var rxLocationFix = PublishSubject<Result<LocationFix>>()
    private var lastLocation: CLLocation? = nil
    var rxDisposeBag: DisposeBag?
    let locationSensor: LocationSensor
    
    // MARK: Lifecycle method
    init(sensor: LocationSensor) {
        locationSensor = sensor
    }
    
    deinit {
        disableTracking()
    }
    
    // MARK: - Tracker Protocol
    func enableTracking() {
        let disposeBag = DisposeBag()
        self.rxDisposeBag = disposeBag
        #if targetEnvironment(simulator)
        #else
        locationSensor.clLocationManager.requestAlwaysAuthorization()
        #endif
        lastLocation = nil
        locationSensor.rxLocation.asObservable().observeOn(MainScheduler.asyncInstance).subscribe { [weak self](event) in
                if let location = event.element {
                    self?.didUpdateLocations(location: location)
                }
        }.disposed(by: disposeBag)
            #if targetEnvironment(simulator)
            #else
            //locationSensor.clLocationManager.delegate = self
            locationSensor.clLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationSensor.clLocationManager.pausesLocationUpdatesAutomatically = false
            locationSensor.clLocationManager.activityType = .automotiveNavigation
            //locationSensor.clLocationManager.distanceFilter = kCLDistanceFilterNone
            locationSensor.clLocationManager.allowsBackgroundLocationUpdates = true
            #endif
        
        locationSensor.startUpdatingLocation()
    }
    
    func disableTracking() {
        locationSensor.stopUpdatingLocation()
        lastLocation = nil
    }
    
    func provideFix() -> PublishSubject<Result<LocationFix>> {
        return rxLocationFix
    }
    
    // MARK: - didUpdateLocations
    func didUpdateLocations(location: CLLocation) {
        //Log.print("[LocationTracker]didUpdateLocations speed %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(location.speed)")
        let distance: Double = self.distance(location: location)
        
        let result = Result.Success(LocationFix(timestamp: location.timestamp.timeIntervalSince1970, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: location.horizontalAccuracy, speed: location.speed, bearing: location.course, altitude: location.altitude, distance: distance))
        
        rxLocationFix.onNext(result)
    }
    
    func isLocationAccurate(accuracy: CLLocationAccuracy) -> Bool {
        return accuracy > 0 && accuracy < maxDistanceAccuracy
    }
    
    func isLocationValid(location: CLLocation) -> Bool {
        return self.isLocationAccurate(accuracy: location.horizontalAccuracy) && location.speed > 0
    }
    
    func distance (location: CLLocation) -> Double {
        defer {
            if (self.isLocationValid(location: location)) {
                lastLocation = location
            }
        }
        
        guard self.isLocationValid(location: location),
              let lastLocation = self.lastLocation else {
            
            //Log.print("[LocationTracker]distance 0    : %{public}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "0")
            return 0
        }
        
        //Log.print("[LocationTracker]location     : %{public}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(location) \(location.speed)")
        //Log.print("[LocationTracker]lastlocation : %{public}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(lastLocation) \(lastLocation.speed)")
        //Log.print("[LocationTracker]distance : %{public}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "\(location.distance(from: lastLocation))")
        return location.distance(from: lastLocation)
    }
}

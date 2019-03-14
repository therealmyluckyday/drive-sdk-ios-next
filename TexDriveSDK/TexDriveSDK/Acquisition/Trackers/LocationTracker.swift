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

class LocationTracker: NSObject, Tracker {
    // MARK: Property
    typealias T = LocationFix
    let locationManager: LocationManager
    private var rxLocationFix = PublishSubject<Result<LocationFix>>()
    var rxDisposeBag: DisposeBag?
    let manager = CLLocationManager()
    
    // MARK: Lifecycle method
    init(sensor: LocationManager) {
        locationManager = sensor
    }
    
    deinit {
        disableTracking()
    }
    
    // MARK: - Tracker Protocol
    func enableTracking() {
        self.rxDisposeBag = DisposeBag()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.rx
            .location
            .subscribe(onNext: { [weak self] location in
                guard let location = location else { return }
                self?.didUpdateLocations(location: location)
            })
            .disposed(by: rxDisposeBag!)
    }
    
    func disableTracking() {
        manager.stopUpdatingLocation()
    }
    
    func provideFix() -> PublishSubject<Result<LocationFix>> {
        return rxLocationFix
    }
    
    // MARK: - didUpdateLocations
    func didUpdateLocations(location: CLLocation) {
        Log.print("Location speed: \(location.speed)")
        let result = Result.Success(LocationFix(timestamp: location.timestamp.timeIntervalSince1970, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, precision: location.horizontalAccuracy, speed: location.speed, bearing: location.course, altitude: location.altitude))
        
        rxLocationFix.onNext(result)
    }
}

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
    private var rxLocationFix = PublishSubject<Result<LocationFix>>()
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
        locationSensor.rxLocation.asObservable().observeOn(MainScheduler.instance).subscribe { [weak self](event) in
                if let location = event.element {
                    self?.didUpdateLocations(location: location)
                }
        }.disposed(by: disposeBag)
        
        locationSensor.startUpdatingLocation()
    }
    
    func disableTracking() {
        locationSensor.stopUpdatingLocation()
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

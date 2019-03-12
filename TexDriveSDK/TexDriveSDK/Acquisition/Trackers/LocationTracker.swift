//
//  LocationTracker.swift
//  TexDriveSDK
//
//  Created by Axa on 24/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import CoreLocation
import RxSwift

class LocationTracker: NSObject, Tracker {
    // MARK: Property
    typealias T = LocationFix
    let locationManager: LocationManager
    private var rxLocationFix = PublishSubject<Result<LocationFix>>()
    var rxDisposeBag: DisposeBag?
    
    // MARK: Lifecycle method
    init(sensor: LocationManager) {
        locationManager = sensor
    }
    
    deinit {
        disableTracking()
    }
    
    // MARK: - Tracker Protocol
    func enableTracking() {
        DispatchQueue.main.async {
            self.rxDisposeBag = DisposeBag()
            guard type(of: self.locationManager.locationManager).authorizationStatus() != .notDetermined else {
                let error = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined requestAlwaysAuthorization()", code: CLError.denied.rawValue, userInfo: nil))
                self.rxLocationFix.onNext(Result.Failure(error))
                return
            }
            
            self.locationManager.rxLocation.asObserver().observeOn(MainScheduler.instance).subscribe { [weak self](event) in
                if let location = event.element {
                    self?.didUpdateLocations(location: location)
                }
                }.disposed(by: self.rxDisposeBag!)
            Log.print("change")
            self.locationManager.change(state: .locationChanges)
        }
    }
    
    func disableTracking() {
        locationManager.change(state: .disabled)
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

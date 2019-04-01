//
//  LocationManager.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 28/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import CoreLocation
import RxSwift

enum LocationManagerState {
    case disabled
    case significantLocationChanges
    case locationChanges
}

public class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager: CLLocationManager
    let slcLocationManager = CLLocationManager()
    public var rxLocation = PublishSubject<CLLocation>()
    public var rxRegion = PublishSubject<CLRegion>()
    var state = LocationManagerState.disabled
    var locationsCount = 0
    
    init(locationManager clLocationManager: CLLocationManager = CLLocationManager()) {
        locationManager = clLocationManager
        clLocationManager.requestAlwaysAuthorization()
    }
    
    func change(state: LocationManagerState) {
        DispatchQueue.main.async() {
            if state != self.state {
                switch state {
                case .disabled:
                    Log.print("State \(state)")
                    self.locationManager.stopUpdatingLocation()
                    self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.state = .disabled
                case .significantLocationChanges:
                    Log.print("State \(state)")
                    self.state = .significantLocationChanges
                    self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                    self.locationManager.stopUpdatingLocation()
                    self.configure(self.slcLocationManager)
                    self.slcLocationManager.startMonitoringSignificantLocationChanges()
                case .locationChanges:
                    if (self.state == .disabled || self.state == .significantLocationChanges) {
                        Log.print("State \(state)")
                        self.slcLocationManager.stopMonitoringSignificantLocationChanges()
                        self.locationManager.stopUpdatingLocation()
                        self.configure(self.locationManager)
                        self.locationManager.startUpdatingLocation()
                    }
                    self.state = .locationChanges
                }
            }
        }
    }
    
    // MARK: - Private Method
    
    func configure(_ clLocationManager: CLLocationManager) {
        clLocationManager.requestAlwaysAuthorization()
        clLocationManager.delegate = self
        clLocationManager.distanceFilter = kCLDistanceFilterNone
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        clLocationManager.activityType = .automotiveNavigation
        
        #if targetEnvironment(simulator)
        #else
        clLocationManager.pausesLocationUpdatesAutomatically = false
        clLocationManager.allowsBackgroundLocationUpdates = true
        #endif
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            self.locationsCount += 1
            guard let _ = locations.last else {
                return
            }
            locations.forEach { (result) in
                self.rxLocation.onNext(result)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        guard let error = error else { return }
        Log.print("didFinishDeferredUpdatesWithError \(error)", type: .Error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.print("didFailWithError \(error)", type: .Error)
        if let error = error as? CLError {
            
            switch error.code {
            case CLError.deferredAccuracyTooLow:
                Log.print("deferredAccuracyTooLow", type: .Error)
                break
            case .locationUnknown:
                Log.print("locationUnknown", type: .Error)
                break
            case .denied:
                Log.print("denied", type: .Error)
                break
            case .network:
                Log.print("network", type: .Error)
                break
            case .headingFailure:
                Log.print("headingFailure", type: .Error)
                break
            case .regionMonitoringDenied:
                Log.print("regionMonitoringDenied", type: .Error)
                break
            case .regionMonitoringFailure:
                Log.print("regionMonitoringFailure", type: .Error)
                break
            case .regionMonitoringSetupDelayed:
                Log.print("regionMonitoringSetupDelayed", type: .Error)
                break
            case .regionMonitoringResponseDelayed:
                Log.print("regionMonitoringResponseDelayed", type: .Error)
                break
            case .geocodeFoundNoResult:
                Log.print("geocodeFoundNoResult", type: .Error)
                break
            case .geocodeFoundPartialResult:
                Log.print("geocodeFoundPartialResult", type: .Error)
                break
            case .geocodeCanceled:
                Log.print("geocodeCanceled", type: .Error)
                break
            case .deferredFailed:
                Log.print("deferredFailed", type: .Error)
                break
            case .deferredNotUpdatingLocation:
                Log.print("deferredNotUpdatingLocation", type: .Error)
                break
            case .deferredAccuracyTooLow:
                Log.print("deferredAccuracyTooLow", type: .Error)
                break
            case .deferredDistanceFiltered:
                Log.print("deferredDistanceFiltered", type: .Error)
                break
            case .deferredCanceled:
                Log.print("deferredCanceled", type: .Error)
                break
            case .rangingUnavailable:
                Log.print("rangingUnavailable", type: .Error)
                break
            case .rangingFailure:
                Log.print("rangingFailure", type: .Error)
                break
            }
        }
    }
    
    // MARK: - Region Monitor
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            self.rxRegion.onNext(region)
            Log.print("Monitor Did Enter Region \(region)")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            self.rxRegion.onNext(region)
            Log.print("Monitor Did Exit Region \(region)")
        }
    }
}


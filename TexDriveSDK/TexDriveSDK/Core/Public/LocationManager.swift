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
    public var rxLocation = PublishSubject<CLLocation>()
    var state = LocationManagerState.disabled
    
    init(locationManager clLocationManager: CLLocationManager = CLLocationManager()) {
        locationManager = clLocationManager
    }
    
    func change(state: LocationManagerState) {
        if state != self.state {
            switch state {
            case .disabled:
                disable()
            case .significantLocationChanges:
                if self.state == .disabled {
                    configure()
                    self.state = .significantLocationChanges
                    locationManager.stopMonitoringSignificantLocationChanges()
                    locationManager.stopUpdatingLocation()
                    locationManager.startMonitoringSignificantLocationChanges()
                }
            case .locationChanges:
                if self.state == .disabled {
                    configure()
                    self.state = .locationChanges
                    locationManager.stopMonitoringSignificantLocationChanges()
                    locationManager.stopUpdatingLocation()
                    locationManager.startUpdatingLocation()
                }
                if self.state == .significantLocationChanges {
                    locationManager.stopMonitoringSignificantLocationChanges()
                    locationManager.stopUpdatingLocation()
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    // MARK: - Private Method
    func disable() {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        self.state = .disabled
    }
    
    func configure() {
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        #if targetEnvironment(simulator)
        #else
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        #endif
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(" ")
        guard let _ = locations.last else {
            return
        }
        locations.forEach { (result) in
            rxLocation.onNext(result)
        }
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
}

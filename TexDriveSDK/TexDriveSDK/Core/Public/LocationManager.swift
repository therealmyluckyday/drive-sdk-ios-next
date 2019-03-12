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
    var locationManager: CLLocationManager
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
                    print("State \(state)")
                    self.disable()
                case .significantLocationChanges:
                    if self.state == .disabled {
                        Log.print("State \(state)")
                        print("State \(state)")
                        self.state = .significantLocationChanges
                        self.locationManager.stopMonitoringSignificantLocationChanges()
                        self.locationManager.stopUpdatingLocation()
                        self.locationManager.delegate = nil
                        self.locationManager = CLLocationManager()
                        self.configure()
                        self.locationManager.startMonitoringSignificantLocationChanges()
                    }
                case .locationChanges:
                    if self.state == .disabled {
                        Log.print("State \(state)")
                        print("State \(state)")
                        self.locationManager.stopMonitoringSignificantLocationChanges()
                        self.locationManager.stopUpdatingLocation()
                        self.locationManager.delegate = nil
                        self.locationManager = CLLocationManager()
                        self.configure()
                        self.locationManager.startUpdatingLocation()
                    }
                    if self.state == .significantLocationChanges {
                        Log.print("State \(state)")
                        print("State \(state)")
                        self.locationManager.stopMonitoringSignificantLocationChanges()
                        self.locationManager.stopUpdatingLocation()
                        self.locationManager.delegate = nil
                        self.locationManager = CLLocationManager()
                        self.configure()
                        self.locationManager.startUpdatingLocation()
                    }
                    self.state = .locationChanges
                }
            }
        }
    }
    
    // MARK: - Private Method
    func disable() {
        DispatchQueue.main.async {
            Log.print("Locations \(self.locationsCount)")
            print("\(Date())Locations \(self.locationsCount)")
            self.locationsCount = 0
            self.locationManager.delegate = nil
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopMonitoringSignificantLocationChanges()
            self.state = .disabled
        }
    }
    
    func configure() {
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        #if targetEnvironment(simulator)
        #else
        locationManager.allowsBackgroundLocationUpdates = true
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
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.print("didFailWithError \(error)", type: .Error)
        print("didFailWithError \(error)")
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

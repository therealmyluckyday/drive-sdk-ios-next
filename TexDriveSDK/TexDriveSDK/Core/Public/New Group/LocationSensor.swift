//
//  LocationSensor.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 05/04/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import CoreLocation
import RxSwift

enum LocationManagerState {
    case disabled
    case significantLocationChanges
    case locationChanges
}

protocol LocationSensorProtocol {
    var rxLocation: PublishSubject<CLLocation> { get }
}

public class LocationSensor: NSObject, LocationSensorProtocol, CLLocationManagerDelegate {
    var rxLocation = PublishSubject<CLLocation>()
    internal var clLocationManager: CLLocationManager
    private let rxDisposeBag = DisposeBag()
    
    init(_ locationManager: CLLocationManager = CLLocationManager()) {
        clLocationManager = locationManager
        super.init()
        self.configureWithRXCoreLocation()
    }
    
    func configureWithRXCoreLocation() {
        clLocationManager.rx
            .location.asObservable().observeOn(MainScheduler.instance).subscribe { [weak self](event) in
                if let location = event.element as? CLLocation {
                    self?.rxLocation.onNext(location)
                }
            }.disposed(by: rxDisposeBag)
    }
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            guard let _ = locations.last else {
                return
            }
            locations.forEach { (result) in
                self.rxLocation.onNext(result)
            }
        }
    }
    // MARK: Redirect for CLLocationManager
    public func startUpdatingLocation() {
        clLocationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        clLocationManager.stopUpdatingLocation()
    }
    
    public func authorizationStatus() -> (CLAuthorizationStatus) {
        return type(of: clLocationManager).authorizationStatus()
    }
    
    // MARK:  CLLocationManagerDelegate error management
    
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
            @unknown default:
                Log.print("unknown", type: .Error)
                break
            }
        }
    }
}

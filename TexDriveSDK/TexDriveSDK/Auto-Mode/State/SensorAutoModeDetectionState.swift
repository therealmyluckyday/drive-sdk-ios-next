//
//  SensorAutoModeDetectionState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 25/02/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

public class SensorAutoModeDetectionState: AutoModeDetectionState, CLLocationManagerDelegate {
    let motionManager: CMMotionActivityManager
    let locationManager: CLLocationManager
    
    init(context: AutoModeContextProtocol, locationManager clLocationManager: CLLocationManager = CLLocationManager(), motionActivityManager: CMMotionActivityManager = CMMotionActivityManager()) {
        motionManager = motionActivityManager
        locationManager = clLocationManager
        super.init(context: context)
    }
    
    override func configure() {
        if !CMMotionActivityManager.isActivityAvailable() {
            Log.print("CMMotionActivityManager ERROR isActivity NOT Available",type: .Error)
        }
        
        switch CMMotionActivityManager.authorizationStatus() {
        case .notDetermined:
            Log.print("CMMotionActivityManager authorizationStatus() == .notDetermined", type: .Error)
            break
        case .restricted:
            Log.print("CMMotionActivityManager authorizationStatus() == .restricted", type: .Error)
            break
        case .denied:
            Log.print("CMMotionActivityManager authorizationStatus() == .denied", type: .Error)
            break
        case .authorized:
            break
        }
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            Log.print("CLLocationManager authorizationStatus() == .notDetermined", type: .Error)
            break
        case .restricted:
            Log.print("CLLocationManager authorizationStatus() == .restricted", type: .Error)
            break
        case .denied:
            Log.print("CLLocationManager authorizationStatus() == .denied", type: .Error)
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            Log.print("CLLocationManager authorizationStatus() == .authorizedWhenInUse")
            break
        }
    }
    
    override func enable() {
        Log.print("enable")
        enableSensor()
    }
    
    override func disable() {
        Log.print("disable")
        disableSensor()
        if let context = self.context {
            context.rxState.onNext(DisabledState(context: context))
        }
    }
    // MARK: - Sensor Method
    func enableMotionSensor() {
        #if targetEnvironment(simulator)
        #else
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            Log.print("startActivityUpdates")
            if let activity = activity, activity.automotive == true {
                self?.drive()
            }
        }
        #endif
    }
    
    func enableLocationSensor() {
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        #if targetEnvironment(simulator)
        #else
        locationManager.disallowDeferredLocationUpdates()
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        #endif
    }
    
    func enableSensor() {
        enableMotionSensor()
        enableLocationSensor()
    }
    
    func disableSensor() {
        disableMotionSensor()
        disableLocationSensor()
    }
    
    func disableMotionSensor() {
        motionManager.stopActivityUpdates()
    }
    
    func disableLocationSensor() {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.print("didUpdateLocations")
        guard let location = locations.last else {
            return
        }
        self.didUpdateLocations(location: location)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.print("\(error)", type: LogType.Error)
        self.stop()
    }
    
    // MARK: - didUpdateLocations
    func didUpdateLocations(location: CLLocation) {
    }
}

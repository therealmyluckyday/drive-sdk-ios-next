//
//  StandbyState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation
import CoreMotion

public class StandbyState: AutoModeDetectionState, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    let motionManager = CMMotionActivityManager()
    
    override func configure() {
        if CMMotionActivityManager.isActivityAvailable() {
            Log.print("CMMotionActivityManager isActivityAvailable")
        }
        else {
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
            Log.print("CMMotionActivityManager authorizationStatus() == .authorized")
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
            Log.print("CLLocationManager authorizationStatus() == .authorizedAlways")
            break
        case .authorizedWhenInUse:
            Log.print("CLLocationManager authorizationStatus() == .authorizedWhenInUse")
            break
        }
    }
    
    func configure(locationManager: CLLocationManager) {
        locationManager.requestAlwaysAuthorization()
        locationManager.stopUpdatingLocation()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        
        //test.delegate = self
        //test.startMonitoringSignificantLocationChanges()
    }
    
    override func enable() {
        Log.print("enable")
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.notDetermined:
            Log.print("notDetermined",type: .Error)
            break
        case CLAuthorizationStatus.restricted:
            Log.print("restricted",type: .Error)
            break
        case CLAuthorizationStatus.denied:
            Log.print("denied",type: .Error)
            break
        case CLAuthorizationStatus.authorizedAlways:
            Log.print("authorizedAlways")
            break
        case CLAuthorizationStatus.authorizedWhenInUse:
            Log.print("authorizedWhenInUse")
            break
        default:
            Log.print("default")
        }
        if let context = self.context {
            self.configure(locationManager: self.locationManager)
            self.start()
        }
        /*motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true {
                self?.start()
            }
        }*/
        super.enable()
    }
    
    override func start() {
        Log.print("start")
        self.stopUpdating()
        if let context = self.context {
            let state = DetectionOfStartState(context: context)
            context.rxState.onNext(state)
            
            state.enable()
        }
    }
    
    override func drive() {
        Log.print("drive")
        self.stopUpdating()
        if let context = self.context {
            let state = DrivingState(context: context)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func disable() {
        Log.print("disable")
        self.stopUpdating()
        if let context = self.context {
            context.rxState.onNext(DisabledState(context: context))
        }
    }
    
    func stopUpdating() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.delegate = nil
        motionManager.stopActivityUpdates()
    }
    
    // MARK : CLLocationManagerDelegate
    private func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.print("didUpdateLocations")
        self.start()
    }
    
    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.print("didFailWithError", type: .Error)
    }	
}

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
    
    func configure(locationManager: CLLocationManager) {
        locationManager.requestAlwaysAuthorization()
        locationManager.disallowDeferredLocationUpdates()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    override func enable() {
        Log.print("enable")
        print("StandbyState enable")
        self.configure(locationManager: self.locationManager)
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            Log.print("startActivityUpdates")
            if let activity = activity, activity.automotive == true {
                self?.drive()
            }
        }
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
        locationManager.delegate = nil
        locationManager.stopMonitoringSignificantLocationChanges()
        motionManager.stopActivityUpdates()
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Log.print("didUpdateLocations")
        
        #if targetEnvironment(simulator)
        self.start()
        #else
        self.checkAutomotiveActivity()
        #endif
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.checkAutomotiveActivity()
        Log.print("didFailWithError")
    }
    
    func checkAutomotiveActivity() {
        Log.print("checkAutomotiveActivity")
        let motionManager = CMMotionActivityManager()
        motionManager.queryActivityStarting(from: Date.init().addingTimeInterval(-60.0*10),
            to: Date.init(),
        to: OperationQueue.main) {[weak self](activityList, error) in
            var activityString = ""
            for (activity) in activityList! {
                if (activity.automotive) {
                    activityString = "Automotive"
                    let dateFormatter = ISO8601DateFormatter()
                    let dateString:String! = dateFormatter.string(from: activity.startDate)
                    if activityString != "" {
                        Log.print(dateString + ": " + activityString)
                    }
                    self?.start()
                }
            }
        }
    }
}

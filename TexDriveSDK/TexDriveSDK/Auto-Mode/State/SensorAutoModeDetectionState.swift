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
import RxSwift
import OSLog

enum SensorState {
    case disable
    case enable
}


let isSimulatorDriveTestingAutoMode = false // Used for Simulator Device Testing

public class SensorAutoModeDetectionState: AutoModeDetectionState, CLLocationManagerDelegate {
    let motionManager: CMMotionActivityManager
    let isMotionActivityPossible: Bool
    let locationManager: LocationManager
    var rxDisposeBag: DisposeBag? = DisposeBag()
    var sensorState: SensorState = .disable
    
    init(context: AutoModeContextProtocol, locationManager clLocationManager: LocationManager, isNeededToRefreshLocationManager: Bool = true, motionActivityManager: CMMotionActivityManager = CMMotionActivityManager()) {
        motionManager = motionActivityManager
        locationManager = clLocationManager
        if #available(iOS 11.0, *) {
            isMotionActivityPossible = CMMotionActivityManager.isActivityAvailable() && CMMotionActivityManager.authorizationStatus() != .denied
        } else {
            isMotionActivityPossible = CMMotionActivityManager.isActivityAvailable()
        }
        super.init(context: context)
        locationManager.autoModeLocationSensor.needToRefreshLocationManager = isNeededToRefreshLocationManager
    }
    
    override func configure() {        
        #if targetEnvironment(simulator)
        #else
        if !CMMotionActivityManager.isActivityAvailable() {
            Log.print("CMMotionActivityManager ERROR isActivity NOT Available",type: .Error)
        }
        
        if #available(iOS 11.0, *) {
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
            @unknown default:
                Log.print("CMMotionActivityManager authorizationStatus() == .unknown", type: .Error)
                break
            }
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
        @unknown default:
            Log.print("CLLocationManager authorizationStatus() == .unknown", type: .Error)
            break
        }
        #endif
    }
    
    override func enable() {
        Log.print("")
        enableSensor()
    }
    
    override func disable() {
        Log.print("")
        disableSensor()
        self.locationManager.change(state: LocationManagerState.disabled)
        if let context = self.context {
            context.rxState.onNext(DisabledState(context: context))
        }
    }
    // MARK: - Sensor Method
    func enableMotionSensor() {
        Log.print("enableMotionSensor")
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
        Log.print("")
        self.locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe (onNext: { [weak self](location) in
            self?.didUpdateLocations(location: location)
        },
            onError: { (error) in
            Log.print("locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe",type: .Error)
        },
            onCompleted: {Log.print("onCompleted locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe",type: .Info)
        },
            onDisposed: {
                Log.print("onDisposed locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe")
        }).disposed(by: self.rxDisposeBag!)
    }
    
    func enableSensor() {
        Log.print("enableSensor")
        if isMotionActivityPossible {
            enableMotionSensor()
        }
        enableLocationSensor()
        sensorState = .enable
    }
    
    func disableSensor() {
        //Log.print("[SensorAutoModeDetectionState] disableSensor" , log: OSLog.texDriveSDK, type: OSLogType.info)
        sensorState = SensorState.disable
        if isMotionActivityPossible {
            disableMotionSensor()
        }
        disableLocationSensor()
    }
    
    func disableMotionSensor() {
        Log.print("disableMotionSensor")
        motionManager.stopActivityUpdates()
    }
    
    func disableLocationSensor() {
        Log.print("disableLocationSensor")
        rxDisposeBag = nil
    }
    
    // MARK: - didUpdateLocations
    func didUpdateLocations(location: CLLocation) {
        Log.print("")
    }
}

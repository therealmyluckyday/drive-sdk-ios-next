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
enum SensorState {
    case disable
    case enable
}


public class SensorAutoModeDetectionState: AutoModeDetectionState, CLLocationManagerDelegate {
    let motionManager: CMMotionActivityManager
    let locationManager: LocationManager
    var rxDisposeBag: DisposeBag? = DisposeBag()
    var sensorState: SensorState = .disable
    let isSimulatorDriveTestingAutoMode = false // Used for Simulator Device Testing
    
    init(context: AutoModeContextProtocol, locationManager clLocationManager: LocationManager, motionActivityManager: CMMotionActivityManager = CMMotionActivityManager()) {
        motionManager = motionActivityManager
        locationManager = clLocationManager
        super.init(context: context)
    }
    
    override func configure() {
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
        } else {
            // Fallback on earlier versions
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
        self.locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe (onNext: { [weak self](location) in
            self?.didUpdateLocations(location: location)
        },
            onError: { (error) in
            Log.print("locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe",type: .Error)
        },
            onCompleted: {Log.print("onCompleted locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe",type: .Info)
        },
            onDisposed: {Log.print("onDisposed locationManager.autoModeLocationSensor.rxLocation.asObserver().subscribe",type: .Info)
        }).disposed(by: self.rxDisposeBag!)
    }
    
    func enableSensor() {
        enableMotionSensor()
        enableLocationSensor()
        sensorState = .enable
    }
    
    func disableSensor() {
        sensorState = SensorState.disable
        disableMotionSensor()
        disableLocationSensor()
    }
    
    func disableMotionSensor() {
        motionManager.stopActivityUpdates()
    }
    
    func disableLocationSensor() {
        rxDisposeBag = nil
    }
    
    // MARK: - didUpdateLocations
    func didUpdateLocations(location: CLLocation) {
        Log.print("-")
    }
}

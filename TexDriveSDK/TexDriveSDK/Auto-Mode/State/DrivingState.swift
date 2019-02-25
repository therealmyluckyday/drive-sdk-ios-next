//
//  DrivingState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation

public class DrivingState: SensorAutoModeDetectionState {
    let thresholdSpeed = CLLocationSpeed(exactly: 10)!
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == false {
                self?.stop()
            }
        }
    }
    
    override func enableLocationSensor() {
        super.enableLocationSensor()
        locationManager.startUpdatingLocation()
    }
    
    override func stop() {
        Log.print("stop")
        disableSensor()
        if let context = self.context {
            let state = DetectionOfStopState(context: context)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func disable() {
        Log.print("disable")
        disableSensor()
        if let context = self.context {
            context.rxState.onNext(DisabledState(context: context))
        }
    }
    
    func stopUpdating() {
        motionManager.stopActivityUpdates()
    }
    
    func forceStop() {
        Log.print("forceStop")
        disableSensor()
        if let context = self.context {
            let state = DetectionOfStopState(context: context)
            context.rxState.onNext(state)
            state.stop()
        }
    }
    
    // MARK: - SensorAutoModeDetectionState
    override func didUpdateLocations(location: CLLocation) {
        Log.print("didUpdateLocation")
        if location.speed < thresholdSpeed {
            self.stop()
        }
    }
}

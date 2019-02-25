//
//  StandbyState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation

public class StandbyState: SensorAutoModeDetectionState {
    let thresholdSpeed = CLLocationSpeed(exactly: 10)!
    
    override func enableLocationSensor() {
        super.enableLocationSensor()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true {
                self?.start()
            }
        }
    }
    
    override func start() {
        Log.print("start")
        disableSensor()
        if let context = self.context {
            let state = DetectionOfStartState(context: context)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func drive() {
        Log.print("drive")
        disableSensor()
        if let context = self.context {
            let state = DrivingState(context: context)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    // MARK: - SensorAutoModeDetectionState
    override func didUpdateLocations(location: CLLocation) {
        Log.print("didUpdateLocation")
        if location.speed > thresholdSpeed {
            self.start()
        }
    }
}

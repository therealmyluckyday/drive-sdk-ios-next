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
    var thresholdSpeed: CLLocationSpeed = CLLocationSpeed(exactly: 10)!
    
    override func enableLocationSensor() {
        DispatchQueue.main.async {
            super.enableLocationSensor()
            self.locationManager.autoModeLocationSensor.change(state: .significantLocationChanges)
        }
    }
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true {
                Log.print("activity = activity, activity.automotive == true")
                self?.start()
            }
        }
    }
    
    override func start() {
        Log.print("start")
        disableSensor()
        if let context = self.context {
            let state = DetectionOfStartState(context: context, locationManager: locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func drive() {
        Log.print("drive")
        disableSensor()
        if let context = self.context {
            let state = DrivingState(context: context, locationManager: locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    // MARK: - SensorAutoModeDetectionState
    override func didUpdateLocations(location: CLLocation) {
        Log.print("Speed: \(location.speed), ThresholdSpeed: \(thresholdSpeed)")
        guard sensorState == .enable else {
            return
        }
        if location.speed > thresholdSpeed {
            Log.print("location.speed > thresholdSpeed")
            self.start()
        }
        else if isSimulatorDriveTestingAutoMode {
            Log.print("isSimulatorDriveTestingAutoMode")
            thresholdSpeed -= 1
        }
    }
}

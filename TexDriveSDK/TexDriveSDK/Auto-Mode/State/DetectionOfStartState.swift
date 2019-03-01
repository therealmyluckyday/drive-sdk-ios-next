//
//  DetectionOfStartState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation

public class DetectionOfStartState: SensorAutoModeDetectionState {
    var firstLocation: CLLocation?
    let thresholdSpeed = CLLocationSpeed(exactly: 20)!
    let timeLowSpeedThreshold = TimeInterval(exactly: 120)!
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true {
                Log.print("activity = activity, activity.automotive == true")
                self?.drive()
            }
        }
    }
    
    override func enableLocationSensor() {
        super.enableLocationSensor()
        locationManager.change(state: .locationChanges)
    }
    
    override func stop() {
        Log.print("stop")
        disableSensor()
        if let context = self.context {
            let state = StandbyState(context: context, locationManager: locationManager)
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
        Log.print("- \(location.speed) \(thresholdSpeed)")
        guard sensorState == .enable else {
            return
        }
        if location.speed > thresholdSpeed {
            Log.print("location.speed > thresholdSpeed")
            self.drive()
            return
        }
        
        if firstLocation == nil {
            firstLocation = location
        }
        else {
            if let firstLocation = firstLocation, location.timestamp.timeIntervalSince1970 - firstLocation.timestamp.timeIntervalSince1970 > timeLowSpeedThreshold {
                Log.print("firstLocation = firstLocation, location.timestamp.timeIntervalSince1970 - firstLocation.timestamp.timeIntervalSince1970 > timeLowSpeedThreshold")
                self.stop()
            }
        }
    }
}

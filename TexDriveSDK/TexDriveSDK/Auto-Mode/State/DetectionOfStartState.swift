//
//  DetectionOfStartState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation
import OSLog

public class DetectionOfStartState: SensorAutoModeDetectionState, TimerProtocol {
    var firstLocation: CLLocation?
    var timer: Timer?
    var thresholdSpeed = CLLocationSpeed(exactly: 10*0.28)!
    let timeLowSpeedThreshold = TimeInterval(exactly: 180)!
    let intervalDelay: TimeInterval = TimeInterval(4*60)
    
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
        locationManager.autoModeLocationSensor.change(state: .locationChanges)
    }
    
    override func enable() {
        super.enable()
        enableTimer(timeInterval: intervalDelay)
    }
    
    override func stop() {
        Log.print("stop")
        disableTimer()
        disableSensor()
        locationManager.autoModeLocationSensor.stopUpdatingLocation()
        if let context = self.context {
            let state = StandbyState(context: context, locationManager: locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func drive() {
        Log.print("drive")
        disableTimer()
        disableSensor()
        if let context = self.context {
            let state = DrivingState(context: context, locationManager: locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    
    // MARK: - SensorAutoModeDetectionState
    override func didUpdateLocations(location: CLLocation) {
        Log.print("Speed: \(location.speed), Accuracy: \(location.verticalAccuracy) \(location.horizontalAccuracy), ThresholdSpeed: \(thresholdSpeed)")
        guard sensorState == .enable, location.speed >= 0 || isSimulatorDriveTestingAutoMode else {
            return
        }
        if location.speed > thresholdSpeed {
            Log.print("location.speed > thresholdSpeed")
            self.drive()
            return
        }
        else if isSimulatorDriveTestingAutoMode {
            Log.print("isSimulatorDriveTestingAutoMode")
            thresholdSpeed -= 1
        }
        
        if firstLocation == nil {
            firstLocation = location
            Log.print("Automode Start: FirstLocation")
        }
        else {
            if let firstLocation = firstLocation, location.timestamp.timeIntervalSince1970 - firstLocation.timestamp.timeIntervalSince1970 > timeLowSpeedThreshold {
                Log.print("firstLocation = firstLocation, location.timestamp.timeIntervalSince1970 - firstLocation.timestamp.timeIntervalSince1970 > timeLowSpeedThreshold")
                self.stop()
            }
        }
    }
    
    
    // MARK: - TimerProtocol
    func enableTimer(timeInterval: TimeInterval){
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self](timer) in
            Log.print("Timer stop")
            self?.stop()
        })
    }
    
    func disableTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer(timeInterval: TimeInterval) {
        Log.print("Should not be called")
    }
}

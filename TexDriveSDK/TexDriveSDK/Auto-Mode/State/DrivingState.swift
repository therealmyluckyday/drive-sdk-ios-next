//
//  DrivingState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation
import CoreMotion

protocol TimerProtocol {
    var intervalDelay: TimeInterval { get }
    var timer: Timer? { get set }
    func enableTimer(timeInterval: TimeInterval)
    func disableTimer()
    func resetTimer(timeInterval: TimeInterval)
}

public class DrivingState: SensorAutoModeDetectionState, TimerProtocol {
    let intervalDelay: TimeInterval
    let thresholdSpeed = CLLocationSpeed(exactly: 10)!
    var timer: Timer?
    var lastActivity: CMMotionActivity?
    
    init(context: AutoModeContextProtocol, locationManager clLocationManager: LocationManager, motionActivityManager: CMMotionActivityManager = CMMotionActivityManager(), interval: TimeInterval = TimeInterval(600)) {
        intervalDelay = interval
        super.init(context: context, locationManager: clLocationManager, motionActivityManager: motionActivityManager)
    }
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity {
                self?.lastActivity = activity
            }
        }
    }
    
    override func enableLocationSensor() {
        super.enableLocationSensor()
        locationManager.change(state: .locationChanges)
    }
    
    override func enable() {
        super.enable()
        enableTimer(timeInterval: intervalDelay)
    }
    
    override func stop() {
        Log.print("stop")
        disableTimer()
        disableSensor()
        if let context = self.context {
            let state = DetectionOfStopState(context: context, locationManager: locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func disable() {
        Log.print("disable")
        disableTimer()
        disableSensor()
        if let context = self.context {
            context.rxState.onNext(DisabledState(context: context))
        }
    }
    
    func forceStop() {
        Log.print("forceStop")
        disableTimer()
        disableSensor()
        if let context = self.context {
            let state = DetectionOfStopState(context: context, locationManager: locationManager)
            context.rxState.onNext(state)
            state.stop()
        }
    }
    
    // MARK: - SensorAutoModeDetectionState
    override func didUpdateLocations(location: CLLocation) {        
        Log.print("- \(location.speed) \(thresholdSpeed)")
        guard sensorState == .enable else {
            return
        }
        resetTimer(timeInterval: intervalDelay)
        if location.speed < thresholdSpeed {
            Log.print("location.speed < thresholdSpeed")
            if let activity = lastActivity, -activity.startDate.timeIntervalSinceNow < 300, activity.automotive {
                Log.print("activity = lastActivity, -activity.startDate.timeIntervalSinceNow < 300, activity.automotive")
            }
            else {
                Log.print("location.speed < thresholdSpeed")
                self.stop()
            }
        }
    }
    
    // MARK: - TimerProtocol
    func enableTimer(timeInterval: TimeInterval){
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self](timer) in
            self?.stop()
        })
    }
    
    func disableTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer(timeInterval: TimeInterval) {
        disableTimer()
        enableTimer(timeInterval: timeInterval)
    }
}

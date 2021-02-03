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
import OSLog

protocol TimerProtocol {
    var intervalDelay: TimeInterval { get }
    var timer: Timer? { get set }
    func enableTimer(timeInterval: TimeInterval)
    func disableTimer()
    func resetTimer(timeInterval: TimeInterval)
}

let minimumDrivingSpeed = CLLocationSpeed(exactly: 10*0.28)!
let maxDelayBeetweenLocationTimeInSecond = 4*60
let locationAccuracyThreshold = Double(20)
public class DrivingState: SensorAutoModeDetectionState, TimerProtocol {
    let intervalDelay: TimeInterval
    let thresholdSpeed = minimumDrivingSpeed
    var timer: Timer?
    var lastActivity: CMMotionActivity?
    var lastLocationDate: Date = Date()
    
    init(context: AutoModeContextProtocol, locationManager clLocationManager: LocationManager, motionActivityManager: CMMotionActivityManager = CMMotionActivityManager(), interval: TimeInterval = TimeInterval(maxDelayBeetweenLocationTimeInSecond)) {
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
        locationManager.autoModeLocationSensor.change(state: .locationChanges)
    }
    
    override func enable() {
        Log.print("enable")
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
        Log.print("location")
        let timeIntervalBetweenLocation = -(lastLocationDate.timeIntervalSinceNow - location.timestamp.timeIntervalSinceNow)
        lastLocationDate = location.timestamp
        guard sensorState == .enable, timeIntervalBetweenLocation < 5, location.speed >= 0, location.horizontalAccuracy < locationAccuracyThreshold || isSimulatorDriveTestingAutoMode else {
                Log.print("isSimulatorDriveTestingAutoMode")
            return
        }
        if location.speed < thresholdSpeed {
            if isMotionActivityPossible {
                self.didUpdateLocationWithMotionActivityActivated()
            } else {
                self.stop()
            }
        } else {
            resetTimer(timeInterval: intervalDelay)
        }	
    }
    
    func didUpdateLocationWithMotionActivityActivated() {
        if let activity = lastActivity, -activity.startDate.timeIntervalSinceNow < 60, activity.automotive {
            resetTimer(timeInterval: intervalDelay)
        }
        else {
            motionManager.queryActivityStarting(from: Date.init().addingTimeInterval(-60.0), to: Date(), to: OperationQueue.main) { [weak self](motions, error) in
                if let motions = motions {
                    for activity in motions {
                        if activity.automotive {
                            Log.print("[Motion] Was in automotive")
                            if let this = self {
                                this.resetTimer(timeInterval: this.intervalDelay)
                            }
                            return
                        }
                    }
                }
                self?.stop()
            }
        }
    }
    
    // MARK: - TimerProtocol
    func enableTimer(timeInterval: TimeInterval){
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self](timer) in
            self?.forceStop()
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

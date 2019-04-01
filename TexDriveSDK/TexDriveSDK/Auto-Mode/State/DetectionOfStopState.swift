//
//  DetectionOfStopState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation
import CoreMotion

public class DetectionOfStopState: SensorAutoModeDetectionState, TimerProtocol {
    let intervalDelay: TimeInterval
    var timer: Timer?
    var firstLocation: CLLocation?
    let thresholdSpeed = CLLocationSpeed(exactly: 10)!
    let timeLowSpeedThreshold = TimeInterval(exactly: 180)!

    init(context: AutoModeContextProtocol, locationManager clLocationManager: LocationManager, motionActivityManager: CMMotionActivityManager = CMMotionActivityManager(), interval: TimeInterval = TimeInterval(4*60)) {
        intervalDelay = interval
        super.init(context: context, locationManager: clLocationManager, motionActivityManager: motionActivityManager)
    }

    override func enableLocationSensor() {
        super.enableLocationSensor()
        locationManager.change(state: .locationChanges)
    }
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true {
                Log.print("let activity = activity, activity.automotive == true")
                self?.drive()
            }
        }
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
        Log.print("- \(location.speed) \(thresholdSpeed)")
        guard sensorState == .enable, -location.timestamp.timeIntervalSinceNow < 5 else {
            return
        }
        resetTimer(timeInterval: intervalDelay)
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
                Log.print("\(location.timestamp.timeIntervalSince1970) - \(firstLocation.timestamp.timeIntervalSince1970) > \(timeLowSpeedThreshold)")
                print("firstLocation = firstLocation, location.timestamp.timeIntervalSince1970 - firstLocation.timestamp.timeIntervalSince1970 > timeLowSpeedThreshold")
                print("\(location.timestamp.timeIntervalSince1970) - \(firstLocation.timestamp.timeIntervalSince1970) > \(timeLowSpeedThreshold)")
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

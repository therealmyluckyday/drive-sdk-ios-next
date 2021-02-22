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
import OSLog

let maxDelayBeetweenLowSpeedTimeInSecond = isSimulatorDriveTestingAutoMode ? 60 : 3*60 // 5*60

public class DetectionOfStopState: SensorAutoModeDetectionState, TimerProtocol {
    let intervalDelay: TimeInterval
    var timer: Timer?
    var firstLocation: CLLocation?
    let thresholdSpeed = CLLocationSpeed(exactly: 20*0.28)!
    var lastLocationDate: Date = Date()
    let timeLowSpeedThreshold = TimeInterval(exactly: maxDelayBeetweenLowSpeedTimeInSecond)!


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
                Log.print("[Motion] let activity = activity, activity.automotive == true")
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
        //self.sendNotification(message: "DetectionOfStop Stop", identifier: "DetectionOfStop")
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
        Log.print("location ")
        let timeIntervalBetweenLocation = -(lastLocationDate.timeIntervalSinceNow - location.timestamp.timeIntervalSinceNow)
        lastLocationDate = location.timestamp
        guard sensorState == .enable, timeIntervalBetweenLocation < 5, location.speed >= 0 || isSimulatorDriveTestingAutoMode else {
                Log.print("location invalid sensorState == .enable, timeIntervalBetweenLocation < 5, location.speed >= 0")
            return
        }
        resetTimer(timeInterval: intervalDelay)
        if location.speed > thresholdSpeed {
            Log.print("Continue to drive location.speed > thresholdSpeed")
            self.drive()
            return
        }
        
        if firstLocation == nil {
            firstLocation = location
        }
        else {
            if let firstLocation = firstLocation, location.timestamp.timeIntervalSince1970 - firstLocation.timestamp.timeIntervalSince1970 > timeLowSpeedThreshold {
                Log.print("Stop trip due to timeinterval")
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
        disableTimer()
        enableTimer(timeInterval: timeInterval)
    }
}

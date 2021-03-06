//
//  StandbyState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation
import CoreMotion

public class StandbyState: SensorAutoModeDetectionState {
    var isSkipSpeed: Bool
    
    init(context: AutoModeContextProtocol, locationManager clLocationManager: LocationManager, isNeededToRefreshLocationManager: Bool = true, motionActivityManager: CMMotionActivityManager = CMMotionActivityManager(), isSkippedSpeed: Bool = false) {
        isSkipSpeed = isSkippedSpeed
        
        super.init(context: context, locationManager: clLocationManager, isNeededToRefreshLocationManager: isNeededToRefreshLocationManager, motionActivityManager: motionActivityManager)
        if (!isMotionActivityPossible) {
            isSkipSpeed = true
        }
    }
    
    override func enableLocationSensor() {
        self.locationManager.change(state: .significantLocationChanges)
        super.enableLocationSensor()
    }
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true, self?.sensorState == .enable {
                Log.print("[Motion]  activity = activity, activity.automotive == true")
                self?.drive()
            }
        }
    }
    
    override func enable() {
        super.enable()
        if (isDebugginModeWithNotificationActivated) {
            self.sendNotification(message: "StandByStateEnable", identifier: "StandByStateEnable")
        }
    }

    override func start() {
        Log.print("start")
        disableSensor()
        if let context = self.context {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let state = DetectionOfStartState(context: context, locationManager: self.locationManager)
                context.rxState.onNext(state)
                state.enable()
            }
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
        Log.print("[StandbyState]didupDateLocation")
        guard canStart(location: location) else {
            return
        }
        self.start()
    }
    
    func canStart(location: CLLocation) -> Bool {
        if isSimulatorDriveTestingAutoMode {
            return true
        }
        if (!isMotionActivityPossible) {
            isSkipSpeed = true
        }
        let thresholdSpeed = CLLocationSpeed(exactly: 20*0.28)!
        guard sensorState == .enable,
              location.timestamp.timeIntervalSinceNow > -5,
              isSkipSpeed || location.speed > thresholdSpeed
        else {
            return false
        }
        
        return true
    }
}

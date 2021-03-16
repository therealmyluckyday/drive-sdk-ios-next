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
    
    override func enableLocationSensor() {
        self.locationManager.change(state: .significantLocationChanges)
        super.enableLocationSensor()
    }
    
    override func enableMotionSensor() {
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true {
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
        guard sensorState == .enable,
              location.timestamp.timeIntervalSinceNow > -5 || isSimulatorDriveTestingAutoMode else {
            return
        }
        self.start()
    }
}

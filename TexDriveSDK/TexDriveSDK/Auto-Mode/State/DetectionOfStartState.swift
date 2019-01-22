//
//  DetectionOfStartState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation
import CoreMotion

public class DetectionOfStartState: AutoModeDetectionState {
    let motionManager = CMMotionActivityManager()

    override func configure() {
        if CMMotionActivityManager.isActivityAvailable() {
            Log.print("CMMotionActivityManager isActivityAvailable")
        }
        else {
            Log.print("CMMotionActivityManager ERROR isActivity NOT Available",type: .Error)
        }
        
        switch CMMotionActivityManager.authorizationStatus() {
        case .notDetermined:
            Log.print("CMMotionActivityManager authorizationStatus() == .notDetermined", type: .Error)
            break
        case .restricted:
            Log.print("CMMotionActivityManager authorizationStatus() == .restricted", type: .Error)
            break
        case .denied:
            Log.print("CMMotionActivityManager authorizationStatus() == .denied", type: .Error)
            break
        case .authorized:
            Log.print("CMMotionActivityManager authorizationStatus() == .authorized")
            break
        }
    }
    
    override func enable() {
        Log.print("enable")
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == true {
                self?.drive()
            }
        }
    }

    override func stop() {
        Log.print("stop")
        self.stopUpdating()
        if let context = self.context {
            let state = StandbyState(context: context)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func drive() {
        Log.print("drive")
        self.stopUpdating()
        if let context = self.context {
            let state = DrivingState(context: context)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func disable() {
        Log.print("disable")
        self.stopUpdating()
        if let context = self.context {
            context.rxState.onNext(DisabledState(context: context))
        }
    }
    
    func stopUpdating() {
        motionManager.stopActivityUpdates()
    }
}

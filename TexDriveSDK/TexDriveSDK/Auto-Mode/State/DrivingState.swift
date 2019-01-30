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

public class DrivingState: AutoModeDetectionState {
    let motionManager = CMMotionActivityManager()
    
    override func enable() {
        Log.print("enable")
        print("Driving enable")
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == false, activity.stationary == true {
                self?.stop()
            }
        }
    }

    override func stop() {
        Log.print("stop")
        self.stopUpdating()
        if let context = self.context {
            let state = DetectionOfStopState(context: context)
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

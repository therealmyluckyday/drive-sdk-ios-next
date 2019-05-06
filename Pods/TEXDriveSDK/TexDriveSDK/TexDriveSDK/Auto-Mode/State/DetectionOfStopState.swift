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

public class DetectionOfStopState: AutoModeDetectionState {
    let motionManager = CMMotionActivityManager()
    
    override func enable() {
        Log.print("enable")
        
        print("DetectionOfStopState enable")
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity, activity.automotive == false {
                self?.stop()
            }
            
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
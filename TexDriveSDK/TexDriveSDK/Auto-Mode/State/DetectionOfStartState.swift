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

    override func enable() {
        Log.print("enable")
        motionManager.startActivityUpdates(to: OperationQueue.main) {[weak self] (activity) in
            if let activity = activity {
                print("automotive : \(activity.automotive)")
                print("walking : \(activity.walking)")
                print("running : \(activity.running)")
                print("cycling : \(activity.cycling)")
            }
            if let activity = activity, activity.automotive == true {
                //Log.print("automotive : \(activity.automotive)")
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
//    
//    // MARK : CLLocationManagerDelegate
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        Log.print("didUpdateLocations")
//        self.drive()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        Log.print("didFailWithError", type: .Error)
//    }
//    
//    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
//        Log.print("locationManagerDidPauseLocationUpdates")
//        self.stop()
//    }
}

//
//  DisabledState.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 17/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift

public class DisabledState: AutoModeDetectionState {
    override func enable() {
        Log.print("enable")
        if let context = self.context {
            let state = StandbyState(context: context, locationManager: context.locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func start() {
        Log.print("start")
        if let context = self.context {
            let state = StandbyState(context: context, locationManager: context.locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
    
    override func drive() {
        Log.print("drive")
        if let context = self.context {
            let state = DrivingState(context: context, locationManager: context.locationManager)
            context.rxState.onNext(state)
            state.enable()
        }
    }
}

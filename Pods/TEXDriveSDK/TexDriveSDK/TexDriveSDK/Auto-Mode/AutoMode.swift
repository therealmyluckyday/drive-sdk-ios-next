//
//  AutoMode.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 16/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation
import CoreMotion

protocol AutoModeContextProtocol: class {
    var rxState: PublishSubject<AutoModeDetectionState> { get }
    var state: AutoModeDetectionState? { get set }
}

class AutoMode: AutoModeContextProtocol {
    // MARK: - Property
    var rxState = PublishSubject<AutoModeDetectionState>() // see to refactor and manage complete stream
    let rxDisposeBag = DisposeBag()
    var state: AutoModeDetectionState?
    let motionManagerTest: CMMotionActivityManager
    
    // MARK: - Lifecycle
    init() {
        let motionManager = CMMotionActivityManager()
        motionManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
            if let activity = activity, activity.automotive == true {
                Log.print("automotive : \(activity.automotive)")
            }
        }
        motionManagerTest = motionManager
    }
    
    // MARK: - Public method
    func enable() {
        Log.print("Enable")
        self.disable()
        let state = StandbyState(context: self)
        self.state = state
        self.rxState.asObserver().observeOn(MainScheduler.asyncInstance).subscribe {[weak self] (event) in
            if let newState = event.element {
                if let state = self?.state {
                    Log.print("PREVIOUS STATE \(state)")
                }
                
                Log.print("NEW STATE \(newState)")
                self?.state = newState
            }
        }.disposed(by: rxDisposeBag)
        
        self.rxState.onNext(state)
        state.enable()
    }
    
    func disable() {
        Log.print("Disable")
        if let state = self.state {
            Log.print("LAST STATE \(state)")
        }
        else {
            Log.print("NO STATE")
        }
        self.state?.disable()
        self.state = nil
    }
    
    func stop() {
        Log.print("stop")
        if let state = self.state {
            Log.print("LAST STATE \(state)")
        }
        else {
            Log.print("NO STATE")
        }
        self.state?.stop()
    }
}

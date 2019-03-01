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
    var rxState = PublishSubject<AutoModeDetectionState>()
    var rxIsDriving = PublishSubject<Bool>()
    let rxDisposeBag = DisposeBag()
    var state: AutoModeDetectionState?
    let locationManager: LocationManager
    
    init(locationManager clLocationManager: LocationManager) {
        locationManager = clLocationManager
    }
    
    // MARK: - Public method
    func enable() {
        Log.print("Enable")
        disable()
        let standbyState = StandbyState(context: self, locationManager: locationManager)
        
        rxState.asObserver().observeOn(MainScheduler.asyncInstance).subscribe {[weak self] (event) in
            if let newState = event.element {
                if let state = self?.state {
                    Log.print("PREVIOUS STATE \(state)")
                }
                
                Log.print("NEW STATE \(newState)")
                self?.state = newState
            }
        }.disposed(by: rxDisposeBag)
        
        rxState.asObserver().observeOn(MainScheduler.asyncInstance).pairwise().subscribe {[weak self] event in
            if let (state1, state2) = event.element {
                Log.print("State 1 : \(state1) , State 2: \(state2)")
                if state1 is DetectionOfStartState, state2 is DrivingState {
                    Log.print("START DETECTED")
                    self?.rxIsDriving.onNext(true)
                }
                if state1 is StandbyState, state2 is DrivingState {
                    Log.print("START DETECTED")
                    self?.rxIsDriving.onNext(true)
                }
                if state1 is DisabledState, state2 is DrivingState {
                    Log.print("START DETECTED")
                    self?.rxIsDriving.onNext(true)
                }
                if state1 is DetectionOfStopState, state2 is StandbyState {
                    Log.print("STOP DETECTED )")
                    self?.rxIsDriving.onNext(false)
                }
                if state1 is DrivingState, state2 is DisabledState {
                    Log.print("STOP DETECTED )")
                    self?.rxIsDriving.onNext(false)
                }
                if state1 is DetectionOfStopState, state2 is DisabledState {
                    Log.print("STOP DETECTED )")
                    self?.rxIsDriving.onNext(false)
                }
            }
            }.disposed(by: rxDisposeBag)
        
        rxState.onNext(standbyState)
        standbyState.enable()
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

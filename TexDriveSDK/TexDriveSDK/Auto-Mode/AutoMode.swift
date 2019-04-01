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
    var locationManager: LocationManager { get }
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
        disable()
        let standbyState = StandbyState(context: self, locationManager: locationManager)
        
        rxState.asObserver().observeOn(MainScheduler.asyncInstance).subscribe {[weak self] (event) in
            if let newState = event.element {
                Log.print("\(newState)")
                print("\(newState)")
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
        standbyState.start()
    }
    
    func disable() {
        self.state?.disable()
        self.state = nil
    }
    
    func stop() {
        self.state?.stop()
    }
    
    func detectionOfStart(){
        if let state = self.state, state is StandbyState {
            state.start()
        }
    }
}

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
import OSLog

protocol AutoModeContextProtocol: class {
    var rxState: PublishSubject<AutoModeDetectionState> { get }
    var state: AutoModeDetectionState? { get set }
    var locationManager: LocationManager { get }
}

enum AutoModeStatus {
    case ServiceNotStarted
    case WaitingScanTrigger
    case ScanningActivity
    case Driving
    case Stopped
}

class AutoMode: AutoModeContextProtocol {
    // MARK: - Property
    var rxState = PublishSubject<AutoModeDetectionState>()
    var rxIsDriving = PublishSubject<Bool>()
    let rxDisposeBag = DisposeBag()
    var state: AutoModeDetectionState?
    let locationManager: LocationManager
    
    var status: AutoModeStatus {
        get {
            if let currentState = state {
                switch currentState {
                case is StandbyState:
                    return .WaitingScanTrigger
                case is DetectionOfStartState:
                    return .ScanningActivity
                case is DrivingState:
                    return .Driving
                case is DetectionOfStopState:
                    return .Stopped
                default:
                    return .ServiceNotStarted
                }
            }
            return AutoModeStatus.ServiceNotStarted
        }
    }
    
    var isServiceStarted: Bool {
        get {
            if let currentState = state {
                return !(currentState is DisabledState)
            }
            return false
        }
    }
    
    init(locationManager clLocationManager: LocationManager) {
        locationManager = clLocationManager
    }
    
    // MARK: - Public method
    func enable() {
        disable()
        let standbyState = StandbyState(context: self, locationManager: locationManager)
        
        rxState.asObserver().observeOn(MainScheduler.asyncInstance).subscribe {[weak self] (event) in
            if let newState = event.element {
                //Log.print("\(newState)")
                self?.state = newState
            }
        }.disposed(by: rxDisposeBag)
        
        rxState.asObserver().observeOn(MainScheduler.asyncInstance).pairwise().subscribe {[weak self] event in
            if let (state1, state2) = event.element {
                //Log.print("State Old New %{private}@" , log: OSLog.texDriveSDK, type: OSLogType.info, "1 : \(state1), 2: \(state2)")
                if state1 is DetectionOfStartState, state2 is DrivingState {
                    Log.print("Start detected")
                    self?.rxIsDriving.onNext(true)
                }
                if state1 is StandbyState, state2 is DrivingState {
                    Log.print("Start detected")
                    self?.rxIsDriving.onNext(true)
                }
                if state1 is DisabledState, state2 is DrivingState {
                    Log.print("Start detected")
                    self?.rxIsDriving.onNext(true)
                }
                if state1 is DetectionOfStopState, state2 is StandbyState {
                    Log.print("Stop detected")
                    self?.rxIsDriving.onNext(false)
                }
                if state1 is DrivingState, state2 is DisabledState {
                    Log.print("Stop detected")
                    self?.rxIsDriving.onNext(false)
                }
                if state1 is DetectionOfStopState, state2 is DisabledState {
                    Log.print("Stop detected")
                    self?.rxIsDriving.onNext(false)
                }
            }
            }.disposed(by: rxDisposeBag)
        
        rxState.onNext(standbyState)
        standbyState.enable()
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
    
    func forceStatusDriving() {
        self.state?.drive()
    }
    
    @available(*, deprecated, message: "Please use disable()")
    func stopService() {
        self.disable()
    }
    
    @available(*, deprecated, message: "Please use enable()")
    func startService() {
        self.enable()
    }
    
    @available(*, deprecated, message: "Please use enable()")
    func forceStatusWaitingScanTrigger() {
        self.enable()
    }
    
    
}

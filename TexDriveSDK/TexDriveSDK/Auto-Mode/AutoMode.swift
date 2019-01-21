//
//  AutoMode.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 16/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import RxSwift
import CoreLocation

class MoveTracker: CLLocationManager {
    
}

protocol AutoModeContextProtocol: class {
    var rxState: PublishSubject<AutoModeDetectionState> { get }
    var state: AutoModeDetectionState? { get set }
}

class AutoMode: AutoModeContextProtocol {
    var rxState = PublishSubject<AutoModeDetectionState>()
    let rxDisposeBag = DisposeBag()
    var state: AutoModeDetectionState?
    let persistantApp = PersistantApp()
    
    func enable() {
        self.disable()
        //self.rxState = PublishSubject<AutoModeDetectionState>()
        let state = StandbyState(context: self)
        self.state = state
        self.rxState.asObserver().observeOn(MainScheduler.asyncInstance).subscribe {[weak self] (event) in
            if let newState = event.element {
                self?.state = newState
            }
        }.disposed(by: rxDisposeBag)
        
        self.rxState.onNext(state)
        state.enable()
    }
    
    func disable() {
        rxState.takeLast(0).subscribe {[weak self](event) in
            if let state = event.element{
                state.disable()
                //self?.rxState.onCompleted()
                //self?.rxState = PublishSubject<AutoModeDetectionState>()
                self?.state = nil
            }
        }.disposed(by: rxDisposeBag)
    }
}

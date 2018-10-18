//
//  FixCollector.swift
//  TexDriveSDK
//
//  Created by Axa on 13/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import RxSwift



class FixCollector {
    // MARK: Property
    private let disposeBag = DisposeBag()
    private var locationTracker: LocationTracker?
    private var batteryTracker: BatteryTracker?
    private var callTracker : CallTracker?
    private var motionTracker : MotionTracker?
    private var rx_errorCollecting = PublishSubject<Error>()
    
    
    // MARK: LifeCycle
    init(newLocationTracker: LocationTracker?, newBatteryTracker: BatteryTracker?, newCallTracker: CallTracker?, newMotionTracker: MotionTracker?) {
        locationTracker = newLocationTracker
        batteryTracker = newBatteryTracker
        callTracker = newCallTracker
        motionTracker = newMotionTracker
    }
    
    
    // MARK: Public Method
    func collect() {
        collectGPS()
        collectBatteryState()
        collectPhoneCall()
    }
    
    func stopCollect() {
        locationTracker?.disableTracking()
        batteryTracker?.disableTracking()
        callTracker?.disableTracking()
        motionTracker?.disableTracking()
    }
    
    // MARK: private Method
    private func collectGPS() {
        self.subscribe(fromProviderFix: locationTracker?.provideFix()) { (locationFix) in
            print("Fix LOCATION altitude : \(locationFix.altitude) timestamp : \(locationFix.timestamp)")
            print("longitude : \(locationFix.longitude) latitude : \(locationFix.latitude)")
        }
        locationTracker?.enableTracking()
    }
    
    private func collectBatteryState() {
        self.subscribe(fromProviderFix: batteryTracker?.provideFix()) { (batteryFix) in
            print("Fix : BATTERY timestamp : \(batteryFix.timestamp)")
            print("level : \(batteryFix.level) state : \(batteryFix.state)")
        }
        
        batteryTracker?.enableTracking()
    }
    
    private func collectPhoneCall() {
        self.subscribe(fromProviderFix: callTracker?.provideFix()) { (callFix) in
            print("Fix : Call timestamp : \(callFix.timestamp)")
            print("state : \(callFix.state)")
        }
        callTracker?.enableTracking()
    }
    
    private func collectMotion() {
        self.subscribe(fromProviderFix: motionTracker?.provideFix()) { (motionFix) in
            print("Fix : motionFix timestamp : \(motionFix.timestamp)")
            print("isCrashed : \(motionFix.isCrashDetected)")
            
        }
    }
    
    private func subscribe<T> (fromProviderFix: PublishSubject<Result<T>>?, resultClosure: @escaping ((T)->())) {
        if let proviveFix = fromProviderFix {
            proviveFix.asObservable().subscribe({ [weak self](event) in
                switch (event.element) {
                case .Success(let fix)?:
                    resultClosure(fix)
                    break
                case .Failure(let Error)?:
                    self?.rx_errorCollecting.onNext(Error)
                    break
                default:
                    break
                }
            })
                .disposed(by: disposeBag)
        }
    }
}

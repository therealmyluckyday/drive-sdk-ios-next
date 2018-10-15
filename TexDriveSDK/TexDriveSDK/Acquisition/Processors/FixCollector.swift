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
    private var rx_errorCollecting = PublishSubject<Error>()
    
    
    // MARK: LifeCycle
    init(newLocationTracker: LocationTracker, newBatteryTracker: BatteryTracker) {
        locationTracker = newLocationTracker
        batteryTracker = newBatteryTracker
    }
    
    
    // MARK: Public Method
    func collect() {
        collectGPS()
        collectBatteryState()
    }
    
    func stopCollect() {
        locationTracker?.disableTracking()
        batteryTracker?.disableTracking()
    }
    
    // MARK: private Method
    private func collectGPS() {
        if let provideFix = locationTracker?.provideFix() {
            provideFix.asObservable().subscribe({ [weak self](event) in
                switch (event.element) {
                case .Success(let locationFix)?:
                    print("Fix LOCATION altitude : \(locationFix.altitude) timestamp : \(locationFix.timestamp)")
                    print("longitude : \(locationFix.longitude) latitude : \(locationFix.latitude)")
                    break
                case .Failure(let Error)?:
                    self?.rx_errorCollecting.onNext(Error)
                    break
                case .none:
                    break
                    
                }
            })
                .disposed(by: disposeBag)
        }
        
        locationTracker?.enableTracking()
    }
    
    private func collectBatteryState() {
        if let provideFix = batteryTracker?.provideFix() {
            provideFix.asObservable().subscribe({ [weak self](event) in
                switch (event.element) {
                case .Success(let batteryFix)?:
                    print("Fix : BATTERY timestamp : \(batteryFix.timestamp)")
                    print("level : \(batteryFix.level) state : \(batteryFix.state)")
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
        
        batteryTracker?.enableTracking()
    }
}

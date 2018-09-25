//
//  FixCollector.swift
//  TexDriveSDK
//
//  Created by Axa on 13/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import RxSwift

protocol Tracker {
    
    func enableTracking()
    func disableTracking()
    func provideFix()
}

public class FixCollector {
    
    private let locationTracker = LocationTracker()
    private let batteryTracker = BatteryTracker()
    private let disposeBag = DisposeBag()
    
    public init() {
        collectGPS()
        //collectBatteryState()
    }
    
    public func collectGPS() {
        
        locationTracker.enableTracking()
        
        locationTracker.locationFix.asObservable().subscribe(onNext: { locationFix in
            print("longitude : \(locationFix.longitude) latitude : \(locationFix.latitude)")
        })
        .disposed(by: disposeBag)
        
    }
    
//    public func collectBatteryState() {
//
//        batteryTracker.enableTracking()
//
//        batteryTracker.rx_batteryFix.asObservable().subscribe(onNext: { batteryFix in
//            print("level : \(batteryFix.level) state : \(batteryFix.batteryState)")
//        })
//            .disposed(by: disposeBag)
//
//    }
}

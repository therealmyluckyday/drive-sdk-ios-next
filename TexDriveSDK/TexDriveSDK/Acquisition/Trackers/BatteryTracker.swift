//
//  BatteryTracker.swift
//  TexDriveSDK
//
//  Created by Axa on 13/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import RxSwift
import RxCocoa

class BatteryTracker: Tracker {
    // MARK: Property
    typealias T = BatteryFix
    private var deviceBatteryState: UIDevice.BatteryState {
        return device.batteryState
    }
    private var deviceBatteryLevel : Float {
        return device.batteryLevel
    }
    private var device : UIDevice
    private var rxBatteryFix = PublishSubject<Result<BatteryFix>>()
    private var rxSubscriptionBatteryState: Disposable?
    private var rxSubscriptionBatteryLevel: Disposable?
    
    // MARK: Tracker Protocol
    func enableTracking() {
        rxSubscriptionBatteryState = NotificationCenter.default.rx.notification(UIDevice.batteryStateDidChangeNotification).subscribe({ [weak self](event) in
            if event.element != nil, let batteryFix = self?.generateBatteryFix() {
                self?.rxBatteryFix.onNext(Result.Success(batteryFix))
            }
        })
        rxSubscriptionBatteryLevel = NotificationCenter.default.rx.notification(UIDevice.batteryLevelDidChangeNotification).subscribe({ [weak self](event) in
            if event.element != nil, let batteryFix = self?.generateBatteryFix()  {
                self?.rxBatteryFix.onNext(Result.Success(batteryFix))
            }
        })
        
        device.isBatteryMonitoringEnabled = true
    }
    
    func disableTracking() {
        device.isBatteryMonitoringEnabled = false
        rxSubscriptionBatteryLevel?.dispose()
        rxSubscriptionBatteryLevel = nil
        rxSubscriptionBatteryState?.dispose()
        rxSubscriptionBatteryState = nil
    }
    
    func provideFix() -> PublishSubject<Result<BatteryFix>> {
        return rxBatteryFix
    }
    
    // MARK: Lifecycle method
    init(sensor: UIDevice) {
        device = sensor
    }
    
    deinit {
        disableTracking()
    }
    
    // MARK: generate Baterry Fix
    func generateBatteryFix() -> BatteryFix {
        var batteryState : BatteryState
        
        switch deviceBatteryState {
        case .unplugged:
            batteryState = .unplugged
        case .charging, .full:
            batteryState = .plugged
        case .unknown:
            batteryState = .unknown
        @unknown default:
            batteryState = .unknown
        }
        
        return BatteryFix(timestamp: Date().timeIntervalSince1970, level: deviceBatteryLevel, state: batteryState)
    }
}

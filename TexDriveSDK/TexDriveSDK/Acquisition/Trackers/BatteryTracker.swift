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
    private var deviceBatteryState: UIDeviceBatteryState {
        return device.batteryState
    }
    private var deviceBatteryLevel : Float {
        return device.batteryLevel
    }
    private var device : UIDevice
    private var rx_batteryFix = PublishSubject<Result<BatteryFix>>()
    private var rx_subscriptionBatteryState: Disposable?
    private var rx_subscriptionBatteryLevel: Disposable?
    
    // MARK: Tracker Protocol
    func enableTracking() {
        rx_subscriptionBatteryState = NotificationCenter.default.rx.notification(NSNotification.Name.UIDeviceBatteryStateDidChange).subscribe({ [weak self](event) in
            if event.element != nil, let batteryFix = self?.generateBatteryFix() {
                self?.rx_batteryFix.onNext(Result.Success(batteryFix))
            }
        })
        rx_subscriptionBatteryLevel = NotificationCenter.default.rx.notification(NSNotification.Name.UIDeviceBatteryLevelDidChange).subscribe({ [weak self](event) in
            if event.element != nil, let batteryFix = self?.generateBatteryFix()  {
                self?.rx_batteryFix.onNext(Result.Success(batteryFix))
            }
        })
        
        device.isBatteryMonitoringEnabled = true
    }
    
    func disableTracking() {
        device.isBatteryMonitoringEnabled = false
        rx_subscriptionBatteryLevel?.dispose()
        rx_subscriptionBatteryState?.dispose()
    }
    
    func provideFix() -> PublishSubject<Result<BatteryFix>> {
        return rx_batteryFix
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
        }
        
        return BatteryFix(timestamp: Date().timeIntervalSince1970, level: deviceBatteryLevel, state: batteryState)
    }
}

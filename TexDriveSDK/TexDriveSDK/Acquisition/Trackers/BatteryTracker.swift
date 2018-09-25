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
    
    var rx_batteryFix: Variable<BatteryFix> = Variable(BatteryFix(fixId: "0", timestamp: Date()))
    
    private var deviceBatteryState: UIDeviceBatteryState {
        return UIDevice.current.batteryState
    }
    
    private var deviceBatteryLevel : Float {
        return UIDevice.current.batteryLevel
    }
    
    func enableTracking() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: .UIDeviceBatteryStateDidChange, object: nil)
    }
    
    func disableTracking() {
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
    }
    
    func provideFix() {
        
    }
    
    @objc func batteryStateDidChange(notification: Notification) {
        var batteryState : BatteryState
        
        switch deviceBatteryState {
        case .unplugged:
            batteryState = .unplugged
        case .charging, .full:
            batteryState = .plugged
        case .unknown:
            batteryState = .unknown
        }
        
        let batteryFix = BatteryFix(fixId: "0", timestamp: Date(), level: deviceBatteryLevel, state: batteryState)
        self.rx_batteryFix.value = batteryFix
    }
    
    deinit {
        disableTracking()
    }
}

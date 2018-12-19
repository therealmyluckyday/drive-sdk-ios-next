//
//  BatteryTrackerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class MockUIDevice: UIDevice {
    override var batteryLevel : Float {
        return mockBatteryLevel
    }
    var mockBatteryLevel = UIDevice.current.batteryLevel
    
    override var batteryState: UIDeviceBatteryState {
        return mockBatteryState
    }
    var mockBatteryState = UIDevice.current.batteryState
    
    override var isBatteryMonitoringEnabled : Bool {
        get {
            return mockIsBatteryMonitoringEnabled
        }
        
        set {
            mockIsBatteryMonitoringEnabled = newValue
        }
    }
    var mockIsBatteryMonitoringEnabled = UIDevice.current.isBatteryMonitoringEnabled
    
}

class BatteryTrackerTests: XCTestCase {
    private var device : MockUIDevice?
    private var tracker : BatteryTracker?
    
    override func setUp() {
        super.setUp()
        device = MockUIDevice()
        tracker = BatteryTracker(sensor: device!)
    }
    
    override func tearDown() {
        UIDevice.current.isBatteryMonitoringEnabled = false
        super.tearDown()
    }
    
    // MARK: func generateBatteryFix() -> BatteryFix
    func test_generateBatteryFix_batteryState_unplugged() {
        let level = Float(-1.0)
        let state = UIDeviceBatteryState.unplugged
        
        let device = MockUIDevice()
        device.mockBatteryLevel = level
        device.mockBatteryState = state
        let batteryTracker = BatteryTracker(sensor: device)
        
        let batteryFix = batteryTracker.generateBatteryFix()
        
        XCTAssertEqual(batteryFix.state, BatteryState.unplugged)
    }
    
    func test_generateBatteryFix_batteryState_charging() {
        let level = Float(-1.0)
        let state = UIDeviceBatteryState.charging
        
        let device = MockUIDevice()
        device.mockBatteryLevel = level
        device.mockBatteryState = state
        let batteryTracker = BatteryTracker(sensor: device)
        
        let batteryFix = batteryTracker.generateBatteryFix()
        
        XCTAssertEqual(batteryFix.state, BatteryState.plugged)
    }
    
    func test_generateBatteryFix_batteryState_full() {
        let level = Float(-1.0)
        let state = UIDeviceBatteryState.charging
        
        let device = MockUIDevice()
        device.mockBatteryLevel = level
        device.mockBatteryState = state
        let batteryTracker = BatteryTracker(sensor: device)
        
        let batteryFix = batteryTracker.generateBatteryFix()
        
        XCTAssertEqual(batteryFix.state, BatteryState.plugged)
    }
    
    func test_generateBatteryFix_batteryState_unknown() {
        let level = Float(-1.0)
        let state = UIDeviceBatteryState.unknown
        
        let device = MockUIDevice()
        device.mockBatteryLevel = level
        device.mockBatteryState = state
        let batteryTracker = BatteryTracker(sensor: device)
        
        let batteryFix = batteryTracker.generateBatteryFix()
        
        XCTAssertEqual(batteryFix.state, BatteryState.unknown)
    }
    
    func test_generateBatteryFix_batteryLevel_min() {
        let level = Float(0.0)
        let state = UIDeviceBatteryState.unknown
        
        let device = MockUIDevice()
        device.mockBatteryLevel = level
        device.mockBatteryState = state
        let batteryTracker = BatteryTracker(sensor: device)
        
        let batteryFix = batteryTracker.generateBatteryFix()
        
        XCTAssertEqual(batteryFix.level, level)
    }
    
    func test_generateBatteryFix_batteryLevel_max() {
        let level = Float(1.0)
        let state = UIDeviceBatteryState.unknown
        
        let device = MockUIDevice()
        device.mockBatteryLevel = level
        device.mockBatteryState = state
        let batteryTracker = BatteryTracker(sensor: device)
        
        let batteryFix = batteryTracker.generateBatteryFix()
        
        XCTAssertEqual(batteryFix.level, level)
    }
    
    func test_generateBatteryFix_batteryLevel_unknown() {
        let level = Float(-1.0)
        let state = UIDeviceBatteryState.unknown
        
        let device = MockUIDevice()
        device.mockBatteryLevel = level
        device.mockBatteryState = state
        let batteryTracker = BatteryTracker(sensor: device)
        
        let batteryFix = batteryTracker.generateBatteryFix()
        
        XCTAssertEqual(batteryFix.level, level)
    }
    
    // MARK: func enableTracking()
    func testEnableTracking_monitoringEnabled() {
        device!.mockIsBatteryMonitoringEnabled = false
        
        tracker!.enableTracking()
        
        XCTAssertTrue(device!.mockIsBatteryMonitoringEnabled)
    }
    
    func testEnableTracking_UIDeviceBatteryStateDidChange() {
        device!.mockBatteryLevel = Float(0.00)
        device!.mockBatteryState = UIDeviceBatteryState.charging
        
        tracker!.enableTracking()
        
        let level = Float(0.75)
        let state = UIDeviceBatteryState.unplugged
        device!.mockBatteryLevel = level
        device!.mockBatteryState = state
        var isSubscritionCalled = false
        let subscription = tracker!.provideFix().asObservable().subscribe { (event) in
            isSubscritionCalled = true
            switch (event.element) {
            case .Success(let batteryFix)?:
                XCTAssertEqual(batteryFix.level, level)
                XCTAssertEqual(batteryFix.state, BatteryState.unplugged)
                break
            default:
                XCTAssertFalse(true)
                break
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        
        subscription.dispose()
        XCTAssertTrue(isSubscritionCalled)
    }
    
    func testEnableTracking_UIDeviceBatteryLevelDidChange() {
        device!.mockBatteryLevel = Float(0.00)
        device!.mockBatteryState = UIDeviceBatteryState.charging
        
        tracker!.enableTracking()
        
        let level = Float(0.75)
        let state = UIDeviceBatteryState.unplugged
        device!.mockBatteryLevel = level
        device!.mockBatteryState = state
        var isSubscritionCalled = false
        let subscription = tracker!.provideFix().asObservable().subscribe { (event) in
            isSubscritionCalled = true
            switch (event.element) {
            case .Success(let batteryFix)?:
                XCTAssertEqual(batteryFix.level, level)
                XCTAssertEqual(batteryFix.state, BatteryState.unplugged)
                break
            default:
                XCTAssertFalse(true)
                break
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)

        subscription.dispose()
        XCTAssertTrue(isSubscritionCalled)
    }
    
    // MARK: func disableTracking()
    func testDisableTracking_monitoringEnabled() {
        device!.mockIsBatteryMonitoringEnabled = true
        
        tracker!.enableTracking()
        
        tracker!.disableTracking()
        
        XCTAssertFalse(device!.mockIsBatteryMonitoringEnabled)
        
        device!.mockBatteryLevel = Float(0.00)
        device!.mockBatteryState = UIDeviceBatteryState.charging
        
        let level = Float(0.75)
        let state = UIDeviceBatteryState.unplugged
        device!.mockBatteryLevel = level
        device!.mockBatteryState = state
        var isSubscritionCalled = false
        let subscription = tracker!.provideFix().asObservable().subscribe { (event) in
            isSubscritionCalled = true
        }
    
        
        NotificationCenter.default.post(name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        
        subscription.dispose()
        XCTAssertFalse(isSubscritionCalled)
        
        
        var isSubscritionStateCalled = false
        let subscriptionState = tracker!.provideFix().asObservable().subscribe { (event) in
            isSubscritionStateCalled = true
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        
        subscriptionState.dispose()
        XCTAssertFalse(isSubscritionStateCalled)
    }
    

}

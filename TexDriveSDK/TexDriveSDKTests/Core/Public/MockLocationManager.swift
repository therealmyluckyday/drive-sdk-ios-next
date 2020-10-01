//
//  MockLocationManager.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 18/09/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

@testable import TexDriveSDK

class MockLocationManager: LocationManager {
    var mockCLLocationManager = MockCLLocationManager()
}

extension Reactive where Base: MockCLLocationManager {
   public var location: Observable<CLLocation?> {
        return self.observe(CLLocation.self, #keyPath(MockCLLocationManager.mockLocation))
    }
}
public class MockLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("YOUHOU")
    }
}

public class MockCLLocationManager: CLLocationManager {
    @objc var mockLocation: CLLocation?
    
    var mockDelegate: MockLocationManagerDelegate?
    
    func mock() {
        self.mockDelegate = MockLocationManagerDelegate()
        self.delegate = self.mockDelegate
    }
    
    static var mockAuthorizationStatus: CLAuthorizationStatus?
    override public class func authorizationStatus() -> CLAuthorizationStatus {
        return mockAuthorizationStatus!
    }
    
    
    var isStartUpdatingLocationCalled = false
    
    override public func startUpdatingLocation() {
        isStartUpdatingLocationCalled = true
    }
    
    var isStopUpdatingLocationCalled = false
    override public func stopUpdatingLocation() {
        isStopUpdatingLocationCalled = true
    }
    
    var mockPausesLocationUpdatesAutomatically = true
    
    override public var pausesLocationUpdatesAutomatically: Bool {
        get {
            return mockPausesLocationUpdatesAutomatically
        }
        set {
            mockPausesLocationUpdatesAutomatically = newValue
        }
    }
    var mockAllowsBackgroundLocationUpdates = false
    override public var allowsBackgroundLocationUpdates : Bool {
        get {
            return mockAllowsBackgroundLocationUpdates
        }
        set {
            mockAllowsBackgroundLocationUpdates = newValue
        }
    }
    
    func send(locations: [CLLocation]) {
        for location in locations {
            self.delegate?.locationManager!(self, didUpdateLocations: [location])
        }
    }
}

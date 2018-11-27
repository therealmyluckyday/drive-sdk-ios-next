//
//  LocationTrackerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 10/10/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import XCTest
import CoreLocation

@testable import TexDriveSDK

class MockLocationManager: CLLocationManager {
    static var mockAuthorizationStatus: CLAuthorizationStatus?
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return mockAuthorizationStatus!
    }
    
    var isStartUpdatingLocationCalled = false
    
    override func startUpdatingLocation() {
        isStartUpdatingLocationCalled = true
    }
    
    var isStopUpdatingLocationCalled = false
    override func stopUpdatingLocation() {
        isStopUpdatingLocationCalled = true
    }
    
    var mockPausesLocationUpdatesAutomatically = true
    
    override var pausesLocationUpdatesAutomatically: Bool {
        get {
            return mockPausesLocationUpdatesAutomatically
        }
        set {
            mockPausesLocationUpdatesAutomatically = newValue
        }
    }
    var mockAllowsBackgroundLocationUpdates = false
    override var allowsBackgroundLocationUpdates : Bool {
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

class LocationTrackerTests: XCTestCase {
    var mockLocationManager : MockLocationManager?
    var locationTracker : LocationTracker?
    
    override func setUp() {
        super.setUp()
        mockLocationManager = MockLocationManager()
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        locationTracker = LocationTracker(sensor: mockLocationManager!)
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    /* TODO
     guard CLLocationManager.authorizationStatus() != .notDetermined else {
     let error = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined", code: CLError.denied.rawValue, userInfo: nil))
     rx_locationFix.onNext(Result.Failure(error))
     //            locationManager.requestAlwaysAuthorization() -> REsponsability to user
     return
     }
 */

    
    // MARK: func enableTracking()
    func testEnableTracking_general() {
        mockLocationManager!.delegate = nil
        mockLocationManager!.distanceFilter = 1000.0
        mockLocationManager!.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        mockLocationManager!.mockPausesLocationUpdatesAutomatically = true
        mockLocationManager!.activityType = CLActivityType.otherNavigation
        mockLocationManager!.allowsBackgroundLocationUpdates = false
        mockLocationManager?.isStartUpdatingLocationCalled = false
        mockLocationManager?.isStopUpdatingLocationCalled = false
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
        locationTracker?.enableTracking()
        
        XCTAssertNotNil(mockLocationManager?.delegate, "")
        XCTAssertEqual(mockLocationManager!.desiredAccuracy, kCLLocationAccuracyBestForNavigation)
        XCTAssertEqual(mockLocationManager!.pausesLocationUpdatesAutomatically, false)
        XCTAssertEqual(mockLocationManager!.activityType, .automotiveNavigation)
        XCTAssertTrue(mockLocationManager!.allowsBackgroundLocationUpdates)
        XCTAssertTrue(mockLocationManager!.isStartUpdatingLocationCalled)
        XCTAssertFalse(mockLocationManager!.isStopUpdatingLocationCalled)
    }
    
    func testEnableTracking_authorizationStatus_NotDetermined() {
        MockLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.notDetermined
        let locationManagerNotDetermined = MockLocationManager()
        let tracker = LocationTracker(sensor: locationManagerNotDetermined)
        
        let subscribe = tracker.provideFix().asObservable().subscribe({ (event) in
            switch event.element {
            case Result.Failure(let error)?:
                let error = error as NSError
                XCTAssertEqual(error.code, CLError.denied.rawValue)
                break
            default:
                XCTAssertTrue(false)
                break
            }
        })
        
        tracker.enableTracking()
        
        subscribe.dispose()
    }
    
    // MARK: func disableTracking()
    func testDisableTracking() {
        mockLocationManager?.isStartUpdatingLocationCalled = false
        mockLocationManager?.isStopUpdatingLocationCalled = false
        
        locationTracker?.disableTracking()
        
        XCTAssertFalse(mockLocationManager!.isStartUpdatingLocationCalled)
        XCTAssertTrue(mockLocationManager!.isStopUpdatingLocationCalled)
    }
    
    // MARK: func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    func testLocationManagerDidUpdateLocation_WithEmptyLocationArray() {
        let locations = [CLLocation]()
        
        // test that even with an empty array, the medthod did not fail
        locationTracker?.locationManager(mockLocationManager!, didUpdateLocations: locations)
        
        XCTAssertTrue(true)
    }
    
    func testLocationManagerDidUpdateLocation_onNext() {
        let date = Date(timeIntervalSinceNow: 9999)
        let latitude = 48.81
        let longitude = 2.3472
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let precision = 5.1
        let speed = 1.2
        let bearing = 1.3
        let altitude = 1.4
        let location = CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: precision, verticalAccuracy: 1.1, course: bearing, speed: speed, timestamp: date)
        
        let locations = [location]
        
        let subscribe = locationTracker!.provideFix().asObservable().subscribe({ (event) in
            switch event.element {
            case Result.Success(let locationFix)?:
                XCTAssertEqual(locationFix.timestamp, date.timeIntervalSince1970)
                XCTAssertEqual(locationFix.longitude, longitude)
                XCTAssertEqual(locationFix.altitude, altitude)
                XCTAssertEqual(locationFix.precision, precision)
                XCTAssertEqual(locationFix.speed, speed)
                XCTAssertEqual(locationFix.bearing, bearing)
                XCTAssertEqual(locationFix.altitude, altitude)
                break
            default:
                XCTAssertTrue(false)
                break
            }
        })
        
        
        locationTracker?.locationManager(mockLocationManager!, didUpdateLocations: locations)
        
        subscribe.dispose()
    }
    
    // MARK: func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    func testLocationManagerDidFailWithError() {
        let clError = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined", code: CLError.geocodeFoundNoResult.rawValue, userInfo: nil))
        let subscribe = locationTracker!.provideFix().asObservable().subscribe({ (event) in
            switch event.element {
            case Result.Failure(let error)?:
                let error = error as NSError
                XCTAssertEqual(error.code, CLError.geocodeFoundNoResult.rawValue)
                break
            default:
                XCTAssertTrue(false)
                break
            }
        })
        
        locationTracker!.locationManager(mockLocationManager!, didFailWithError: clError)
        
        subscribe.dispose()
    }
}

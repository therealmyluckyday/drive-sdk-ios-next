//
//  LocationManagerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 01/03/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest

class LocationManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEnableTracking_general() {
        XCTAssert(false)
//        mockLocationManager!.delegate = nil
//        mockLocationManager!.distanceFilter = 1000.0
//        mockLocationManager!.desiredAccuracy = kCLLocationAccuracyThreeKilometers
//        mockLocationManager!.mockPausesLocationUpdatesAutomatically = true
//        mockLocationManager!.activityType = CLActivityType.otherNavigation
//        mockLocationManager!.allowsBackgroundLocationUpdates = false
//        mockLocationManager?.isStartUpdatingLocationCalled = false
//        mockLocationManager?.isStopUpdatingLocationCalled = false
//        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.authorizedAlways
//        locationTracker?.enableTracking()
//
//        XCTAssertNotNil(mockLocationManager?.delegate, "")
//        XCTAssertEqual(mockLocationManager!.desiredAccuracy, kCLLocationAccuracyBestForNavigation)
//        XCTAssertEqual(mockLocationManager!.pausesLocationUpdatesAutomatically, false)
//        XCTAssertEqual(mockLocationManager!.activityType, .automotiveNavigation)
//        XCTAssertTrue(mockLocationManager!.allowsBackgroundLocationUpdates)
//        XCTAssertTrue(mockLocationManager!.isStartUpdatingLocationCalled)
    }
    
    func testEnableTracking_authorizationStatus_NotDetermined() {
//        MockCLLocationManager.mockAuthorizationStatus = CLAuthorizationStatus.notDetermined
//        let locationManagerNotDetermined = MockCLLocationManager()
//        let tracker = LocationTracker(sensor: locationManagerNotDetermined)
//
//        let subscribe = tracker.provideFix().asObservable().subscribe({ (event) in
//            switch event.element {
//            case Result.Failure(let error)?:
//                let error = error as NSError
//                XCTAssertEqual(error.code, CLError.denied.rawValue)
//                break
//            default:
//                XCTAssertTrue(false)
//                break
//            }
//        })
//
//        tracker.enableTracking()
//
//        subscribe.dispose()
        XCTAssert(false)
    }
    
    // MARK: func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    func testLocationManagerDidFailWithError() {
        
//        let clError = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined", code: CLError.geocodeFoundNoResult.rawValue, userInfo: nil))
//        let subscribe = locationTracker!.provideFix().asObservable().subscribe({ (event) in
//            switch event.element {
//            case Result.Failure(let error)?:
//                let error = error as NSError
//                XCTAssertEqual(error.code, CLError.geocodeFoundNoResult.rawValue)
//                break
//            default:
//                XCTAssertTrue(false)
//                break
//            }
//        })
//
//        locationTracker!.locationManager(mockLocationManager!, didFailWithError: clError)
//
//        subscribe.dispose()
        XCTAssert(false)
    }

}

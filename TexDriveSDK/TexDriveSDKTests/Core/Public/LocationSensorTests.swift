//
//  LocationManagerTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 01/03/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest
import CoreLocation
@testable import TexDriveSDK
@testable import RxSwift

class LocationSensorTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    // MARK: - public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    func testDidUpdateLocations() {
        let locationSensor = LocationSensor()
        let expectation = XCTestExpectation(description: #function)
        locationSensor.rxLocation.asObserver().observe(on: MainScheduler.instance) .subscribe { (event) in
            if event.element != nil {
                expectation.fulfill()
            }
        }.disposed(by: disposeBag)
        let location = CLLocation(latitude: CLLocationDegrees(exactly: 18)!, longitude: CLLocationDegrees(exactly: 12)!)
        locationSensor.locationManager(locationSensor.clLocationManager, didUpdateLocations: [location])
        wait(for: [expectation], timeout: 0.3)
    }
    
    // MARK: func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    func testLocationManagerDidFailWithError() {
        let locationSensor = LocationSensor()
        let expectation = XCTestExpectation(description: #function)
        expectation.isInverted = true
        locationSensor.rxLocation.asObserver().observe(on: MainScheduler.instance) .subscribe { (event) in
            if event.element != nil {
                expectation.fulfill()
            }
            }.disposed(by: disposeBag)
        let clError = CLError(_nsError: NSError(domain: "CLLocationManagerNotDetermined", code: CLError.geocodeFoundNoResult.rawValue, userInfo: nil))
        locationSensor.locationManager(locationSensor.clLocationManager, didFailWithError: clError)
        wait(for: [expectation], timeout: 0.2)
    }

}

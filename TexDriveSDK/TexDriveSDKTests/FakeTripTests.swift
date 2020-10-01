//
//  FakeTripTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 16/09/2020.
//  Copyright © 2020 Axa. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
import os

@testable import TexDriveSDK

class FakeTripTests: XCTestCase {
    var rxDisposeBag: DisposeBag = DisposeBag()
        
    override func setUpWithError() throws {
        self.rxDisposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFakeLocationManagerLoadTrips() {
        let fakeLocationManager = FakeLocationManager()
        fakeLocationManager.loadTrip(intervalBetweenGPSPointInMilliSecond: 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

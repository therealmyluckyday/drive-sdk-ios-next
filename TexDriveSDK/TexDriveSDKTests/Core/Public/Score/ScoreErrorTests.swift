//
//  ScoreErrorTests.swift
//  TexDriveSDKTests
//
//  Created by Erwan Masson on 07/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import XCTest
@testable import TexDriveSDK

class ScoreErrorTests: XCTestCase {
    // MARK: - init?(dictionary: [String: Any])
    func testInit_trip_too_short() {
        let tripId = TripId(uuidString: "6AC26AD5-6D67-483F-835D-44B4F040418C")
        let dictionary = ["status": "trip_too_short", "trip_id": tripId!.uuidString, "score_type": "temporary", "status_details": ["not_enough_locations"]
            ] as [String : Any]
        
        let scoreError = ScoreError(dictionary: dictionary)
        XCTAssertNotNil(scoreError)
        XCTAssertEqual(scoreError!.status, ScoreStatus.tooShort)
        XCTAssertEqual(scoreError!.tripId, tripId!)
        XCTAssertEqual(scoreError!.details.first, ExceptionScoreStatus.lowPrecisionTrip)
    }
    
    func testInit_trip_invalid() {
        let tripId = TripId(uuidString: "6AC26AD5-6D67-483F-835D-44B4F040428C")
        let dictionary = ["status": "trip_invalid", "trip_id": tripId!.uuidString, "score_type": "temporary", "status_details": ["low_speed_trip"]
            ] as [String : Any]
        
        
        let scoreError = ScoreError(dictionary: dictionary)
        XCTAssertNotNil(scoreError)
        XCTAssertEqual(scoreError!.status, ScoreStatus.invalid)
        XCTAssertEqual(scoreError!.tripId, tripId!)
        XCTAssertEqual(scoreError!.details.first, ExceptionScoreStatus.lowSpeedTrip)
    }
    
    func testInit_trip_too_long() {
        let tripId = TripId(uuidString: "6AC26AD5-6D67-483F-835D-44B4F040438C")
        let dictionary = ["status": "trip_too_long", "trip_id": tripId!.uuidString, "score_type": "temporary", "status_details": ["trip_too_long"]
            ] as [String : Any]
        
        
        let scoreError = ScoreError(dictionary: dictionary)
        XCTAssertNotNil(scoreError)
        XCTAssertEqual(scoreError!.status, ScoreStatus.tooLong)
        XCTAssertEqual(scoreError!.tripId, tripId!)
        XCTAssertEqual(scoreError!.details.first, ExceptionScoreStatus.tripTooLong)
    }
    
    func testInit_no_external_data() {
        let tripId = TripId(uuidString: "6AC26AD5-6D67-483F-835D-44B4F040448C")
        let dictionary = ["status": "no_external_data", "trip_id": tripId!.uuidString, "score_type": "temporary", "status_details":["no_mapping_data"]
            ] as [String : Any]
        
        
        let scoreError = ScoreError(dictionary: dictionary)
        XCTAssertNotNil(scoreError)
        XCTAssertEqual(scoreError!.status, ScoreStatus.noExternalData)
        XCTAssertEqual(scoreError!.tripId, tripId!)
        XCTAssertEqual(scoreError!.details.first, ExceptionScoreStatus.noMappingData)
    }
    
    func testInit_error() {
        let tripId = TripId(uuidString: "6AC26AD5-6D67-483F-835D-44B4F040448C")
        let dictionary = ["status": "error", "trip_id": tripId!.uuidString, "score_type": "temporary", "status_details": ["unknown sdffds error"]
            ] as [String : Any]
        
        
        let scoreError = ScoreError(dictionary: dictionary)
        XCTAssertNotNil(scoreError)
        XCTAssertEqual(scoreError!.status, ScoreStatus.error)
        XCTAssertEqual(scoreError!.tripId, tripId!)
        XCTAssertEqual(scoreError!.details.count, 0)
    }
    
}

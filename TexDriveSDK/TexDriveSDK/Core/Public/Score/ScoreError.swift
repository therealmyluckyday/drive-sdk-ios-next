//
//  ScoreError.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 04/01/2019.
//  Copyright © 2019 Axa. All rights reserved.
//

import UIKit
// https://github.com/axadil/tex-platform-gateway/blob/master/score_gw/application/data/__init__.py
enum ScoreType: String {
    case temporary = "temporary"
    case final = "final"
}

enum ScoreStatus: String {
    case ok = "ok"
    case pending = "pending"
    case tooShort = "trip_too_short"
    case invalid = "trip_invalid"
    case tooLong = "trip_too_long"
    case noExternalData = "no_external_data"
    case error = "error"
}


// Mapping between status and status detail
//LowPrecisionTrip = ScoreStatus.trip_too_short
//TripTooShort = ScoreStatus.trip_too_short
//TripTooLong = ScoreStatus.trip_too_long
//LowSpeedTrip = ScoreStatus.trip_invalid
//HighSpeedTrip = ScoreStatus.trip_invalid
//NoMappingData = ScoreStatus.no_external_data
//OutOfRoadTrip = ScoreStatus.trip_invalid
//NoLocations = ScoreStatus.trip_invalid
//NotEnoughLocations = ScoreStatus.trip_invalid
//DataQualityIssue = ScoreStatus.trip_invalid

enum ExceptionScoreStatus: String {
    case lowPrecisionTrip = "not_enough_locations"
    case tripTooShort = "trip_too_short"
    case tripTooLong = "trip_too_long"
    case lowSpeedTrip = "low_speed_trip"
    case highSpeedTrip = "high_speed_trip"
    case noMappingData = "no_mapping_data"
    case outOfRoadTrip = "out_of_road_trip"
    case noLocations = "no_locations"
}

struct ScoreError: Error {
    let details: [ExceptionScoreStatus]
    let status: ScoreStatus
    let tripId: TripId
    lazy var localizedDescription: String =  {
        "Error on score request tripId: \(self.tripId.uuidString) status: \(self.status) message: \(self.details)"
    }()
    
    init?(dictionary: [String: Any]) {
        guard let statusString = dictionary["status"] as? String,
            let tripIdString = dictionary["trip_id"] as? String,
            let status = ScoreStatus.init(rawValue: statusString),
            let tripId = TripId(uuidString: tripIdString)
            else { return nil }
        var details = [ExceptionScoreStatus]()
        if let messages = dictionary["status_details"] as? [String] {
            for message in messages {
                if let statusDetail = ExceptionScoreStatus.init(rawValue: message) {
                    details.append(statusDetail)
                }
            }
        }
        self.details = details
        self.status = status
        self.tripId = tripId
    }
}

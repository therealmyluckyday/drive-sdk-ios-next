//
//  Score.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 03/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

public class ParseError: Error {
    var localizedDescription: String = "Parsing Error"
    
}

public struct Score: CustomStringConvertible {
    public let tripId: TripId
    public let global: Double
    public let speed: Double
    public let acceleration: Double
    public let braking: Double
    public let smoothness: Double
    public let startDate: Date
    public let endDate: Date
    public let distance: Double
    public let duration: Double
    
    
    // MARK : - CustomStringConvertible
    public var description: String {
        get {
            return "tripId \(tripId), start date \(startDate), end date \(endDate),, global \(global), speed \(speed), acceleration \(acceleration), braking \(braking), smoothness \(smoothness), distance \(distance), duration \(duration)"
        }
    }
    
    init?(dictionary: [String: Any]) {
        guard let scoreDictionary = dictionary["scores_dil"] as? [String: Any],
            let tripInfoDictionary = dictionary["trip_info"] as? [String: Any],
            let distanceDouble = tripInfoDictionary["length"] as? Double,
            let durationDouble = tripInfoDictionary["duration"] as? Double,
            let startDouble = dictionary["start_time"] as? Double,
            let endDouble = dictionary["end_time"] as? Double,
        let globalParsed = scoreDictionary["expert"] as? Double,
        let speedParsed = scoreDictionary["speed"] as? Double,
        let accelerationParsed = scoreDictionary["acceleration"] as? Double,
        let brakingParsed = scoreDictionary["braking"] as? Double,
        let tripIdStringParsed = dictionary["trip_id"] as? String,
        let tripIdParsed = TripId(uuidString: tripIdStringParsed),
        let smoothnessParsed = scoreDictionary["smoothness"] as? Double
            else {
            return nil
        }
        startDate = Date(timeIntervalSince1970: TimeInterval(startDouble)/1000)
        endDate = Date(timeIntervalSince1970: TimeInterval(endDouble)/1000)
        distance = distanceDouble
        duration = durationDouble
        global = globalParsed
        speed = speedParsed
        acceleration = accelerationParsed
        braking = brakingParsed
        smoothness = smoothnessParsed
        tripId = tripIdParsed
    }
    
    internal init(tripId: TripId, global: Double, speed: Double, acceleration: Double, braking: Double, smoothness: Double, startDouble: Double, endDouble: Double, distance: Double, duration: Double) {
        self.global = global
        self.speed = speed
        self.acceleration = acceleration
        self.braking = braking
        self.smoothness = smoothness
        self.tripId = tripId
        self.startDate = Date(timeIntervalSince1970: TimeInterval(startDouble)/1000)
        self.endDate = Date(timeIntervalSince1970: TimeInterval(endDouble)/1000)
        self.distance = distance
        self.duration = duration
    }
}

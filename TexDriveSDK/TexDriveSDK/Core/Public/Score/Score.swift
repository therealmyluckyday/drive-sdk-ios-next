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
    // MARK : - CustomStringConvertible
    public var description: String {
        get {
            return "tripId \(tripId), global \(global), speed \(speed), acceleration \(acceleration), braking \(braking), smoothness \(smoothness)"
        }
        
    }
    
    init?(dictionary: [String: Any]) {
        guard let scoreDictionary = dictionary["scores_dil"] as? [String: Any],
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
        global = globalParsed
        speed = speedParsed
        acceleration = accelerationParsed
        braking = brakingParsed
        smoothness = smoothnessParsed
        tripId = tripIdParsed
    }
    
    internal init(tripId: TripId, global: Double, speed: Double, acceleration: Double, braking: Double, smoothness: Double) {
        self.global = global
        self.speed = speed
        self.acceleration = acceleration
        self.braking = braking
        self.smoothness = smoothness
        self.tripId = tripId
    }
}

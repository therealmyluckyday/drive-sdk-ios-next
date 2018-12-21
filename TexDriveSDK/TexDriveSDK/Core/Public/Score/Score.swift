//
//  Score.swift
//  TexDriveSDK
//
//  Created by Erwan Masson on 03/12/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

import Foundation

class ParsingError: Error {
    var localizedDescription: String = "Parsing Error"
    
}

public struct Score {
    let tripId: NSUUID
    let global: Double
    let speed: Double
    let acceleration: Double
    let braking: Double
    let smoothness: Double
    
    init?(dictionary: [String: Any]) {
        guard let scoreDictionary = dictionary["scores_dil"] as? [String: Any],
        let globalParsed = scoreDictionary["expert"] as? Double,
        let speedParsed = scoreDictionary["speed"] as? Double,
        let accelerationParsed = scoreDictionary["acceleration"] as? Double,
        let brakingParsed = scoreDictionary["braking"] as? Double,
        let tripIdStringParsed = dictionary["trip_id"] as? String,
        let tripIdParsed = NSUUID(uuidString: tripIdStringParsed),
        let smoothnessParsed = scoreDictionary["smoothness"] as? Double
            else {
            return nil
        }
        print(scoreDictionary)
        global = globalParsed
        speed = speedParsed
        acceleration = accelerationParsed
        braking = brakingParsed
        smoothness = smoothnessParsed
        tripId = tripIdParsed
    }
    
    internal init(tripId: NSUUID, global: Double, speed: Double, acceleration: Double, braking: Double, smoothness: Double) {
        self.global = global
        self.speed = speed
        self.acceleration = acceleration
        self.braking = braking
        self.smoothness = smoothness
        self.tripId = tripId
    }
}

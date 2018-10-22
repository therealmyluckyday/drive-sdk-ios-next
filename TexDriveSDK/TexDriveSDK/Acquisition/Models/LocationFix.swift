//
//  LocationFix.swift
//  TexDriveSDK
//
//  Created by Axa on 25/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

class LocationFix : Fix {
    // MARK: Property
    let latitude: Double
    let longitude: Double
    let precision: Double
    let speed: Double
    let bearing: Double
    let altitude: Double
    let timestamp: TimeInterval
    
    // MARK: LifeCycle
    init(timestamp: TimeInterval, latitude: Double, longitude: Double, precision: Double, speed: Double, bearing: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.precision = precision
        self.speed = speed
        self.bearing = bearing
        self.altitude = altitude
        self.timestamp = timestamp
    }
    
    // MARK: Protocol CustomStringConvertible
    var description: String {
        get {
            var description = "----- LocationFix: timestamp:\(self.timestamp) latitude: \(self.latitude), longitude: \(self.longitude)"
            description += "LocationFix: precision:\(self.precision) speed: \(self.speed), bearing: \(self.bearing)"
            description += "LocationFix: altitude:\(self.altitude) ------"
            return description
        }
        set {
            
        }
    }
}

//
//  LocationFix.swift
//  TexDriveSDK
//
//  Created by Axa on 25/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

class LocationFix : Fix {
    // MARK: Property
    var latitude : Double
    var longitude : Double
    var precision : Double
    var speed : Double
    var bearing : Double
    var altitude : Double
    
    // MARK: LifeCycle
    init(timestamp: Date, latitude: Double, longitude: Double, precision: Double, speed: Double, bearing: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.precision = precision
        self.speed = speed
        self.bearing = bearing
        self.altitude = altitude
        super.init(date: timestamp)
    }
    
    // MARK: Protocol CustomStringConvertible
    override var description: String {
        get {
            var description = "----- LocationFix: date:\(self.timestamp) latitude: \(self.latitude), longitude: \(self.longitude)"
            description += "LocationFix: precision:\(self.precision) speed: \(self.speed), bearing: \(self.bearing)"
            description += "LocationFix: altitude:\(self.altitude) ------"
            return description
        }
        set {
            
        }
    }
}

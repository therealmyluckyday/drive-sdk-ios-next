//
//  LocationFix.swift
//  TexDriveSDK
//
//  Created by Axa on 25/09/2018.
//  Copyright © 2018 Axa. All rights reserved.
//

class LocationFix : Fix {
    // MARK: Property
    let timestamp: Date
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
        self.timestamp = timestamp
    }
}
